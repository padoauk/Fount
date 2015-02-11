# encoding: utf-8

=begin
 Copyright 2013, 2014 Toshinao Ishii All Rights Reserved
=end

require 'singleton'

require 'common'
require 'byte_array_editor'

class PacketManager
  include Singleton
  include BaseTypeCellUtil

  def initialize
    update_all
    @lock = Mutex.new
  end

  #
  # @packet_segments[p.id][segment_id] => Array of Cells
  #
  def update_all
    @packet_editors = Hash.new
    @packet_cells = Hash.new
    @custom_cells = Hash.new
    @cell_val_cache = Hash.new # cell to val in byte array of basic type
    @time_generated = Hash.new # last time each packet was generated

    Packet.all.each do |p|
      create_packet_cells(p)
      @time_generated[p.id] = 0
    end

    Cell.all.each do |c|
      update_cell_cache(c)
    end

    return
  end

  def update_cell( cell )
    return false unless cell.kind_of?(Cell)

    update_cell_cache( cell )
  end

  def update_streams
    list_updated = Array.new
    Packet.all.each do |p|
      next unless _is_true(p.is_active)
      flag = update_stream(p)
      list_updated.push(p) if flag
    end

    return list_updated
  end

  def update_stream( packet )
    now = Time.now
    # packet.period is in milisecond
    if (now.to_f - @time_generated[packet.id].to_f) * 1000  < packet.period.to_i
      return false
    end

    @lock.synchronize do
      @time_generated[packet.id] = Time.now
      @packet_editors[packet.id] = realize_packet( packet )
    end

    return true
  end

  def get_stream( packet )
    arr = nil
    @lock.synchronize do
      arr = @packet_editors[packet.id].arr.pack('C*')
    end

    return arr
  end

  ################################################
  private

  #
  def create_packet_cells( packet )
    cells = Array.new
    Cell.where(packet_id: packet.id).order(:seq).each do |c|
      cells.push(c)
      unless base_type?(c) then
        @custom_cells[c] = CustomCellInfo.new(c.cell_type, c.byte_pos, c.bit_pos)
      end
    end

    @packet_cells[packet.id] = fix_abbreviated(cells)
  end

  def fix_abbreviated(cells)
    unless cells.kind_of?(Array) then
      return nil
    end

    next_byte_pos = 'init' # value is nil if next_byte_pos is undefined

    cells.each do |c|
      byte_pos_defined = false
      size_defined = false

      # byte_pos explicitly defined
      byte_pos = c.byte_pos
      if byte_pos.kind_of?(String) && 0 < byte_pos.length && byte_pos != '..' then
        byte_pos_defined = true
      else
        byte_pos = ''
      end

      # byte_pos abbreviated
      if false == byte_pos_defined then
        if next_byte_pos == 'init' then # the initial cell of the packet
          byte_pos = '0'
          byte_pos_defined = true
        elsif nil != next_byte_pos then # byte_pos is defined by byte_pos of the cell just before
          if c.byte_pos == '..'
            byte_pos = (Integer(next_byte_pos) - 1).to_s
          else
            byte_pos = next_byte_pos
          end
          byte_pos_defined = true
        end
      end
      if byte_pos_defined then
        c.byte_pos = byte_pos
      end

      # define cell size
      sz = str2cell_size_in_bit(c.size)
      if 0 < sz then
        size_defined = true
      else # abbreviated
        begin
          sz = size_in_bit_of_type(c.cell_type)
        rescue => e
          sz = 0
        end
        if 0 < sz then
          size_defined = true
        end
      end
      if size_defined then
        c.size = sz.to_s
      end

      c.save

      # byte_pos for the next cell
      if byte_pos_defined && size_defined then
        next_byte_pos = (byte_pos.to_i + (sz / 8.0).ceil).to_s
      else
        next_byte_pos = nil
      end

    end

    return cells
  end

  # return byte array of the packet specified
  def realize_packet( packet )

    unless @packet_cells.has_key?(packet.id) then
      return nil
    end

    cells = @packet_cells[packet.id]
    editor = ByteArrayEditor.new

    byte_pos = '0' # initial value

    cells.each do |c|

      # current byte_pos
      if c.byte_pos == '' then
        # nothing to do
      elsif c.byte_pos == '..' then
        if byte_pos != '0' then
          byte_pos = (byte_pos.to_i - 1).to_s
        end
      else
        byte_pos = c.byte_pos
      end

      if base_type?(c.cell_type) then
        realize_base_cell(editor, c, byte_pos)
        size = calc_cell_size_in_bit(c)
      else
        realize_custom_cell(editor, c, byte_pos)
        size = @custom_cells[c].cell.size_total_in_bit
      end

      # for next cell
      byte_pos = (byte_pos.to_i + (size / 8.0).ceil).to_s

    end

    return editor

  end

  def realize_custom_cell( editor, cell, byte_pos )

    cell_info = @custom_cells[cell]
    cb = cell_info.cell
    cb.set_editor(editor)
    bit_pos  = cell_info.bit_pos
    begin
      cb.calc
      # cell.vals is updated by cell.calc, and cell.types may be.
      btypes = cb.types
      vals   = cb.vals
      raise InvalidCustomCell if btypes.length != vals.length
      byte_pos_inc = 0
      bit_pos_inc = 0
      for i in 0 .. btypes.length-1 do
        inc = size_in_bit_of_type(btypes[i])
        editor.set_val(vals[i], btypes[i], byte_pos.to_i + byte_pos_inc, bit_pos + bit_pos_inc, inc)

        bit_pos_inc += inc % 8
        byte_pos_inc += (bit_pos_inc+inc)/8
        bit_pos_inc = bit_pos_inc % 8
      end
    rescue => e
      raise InvalidCustomCell, "custom cell class #{type} error in evaluation"
    end

  end

  def realize_base_cell( editor, cell, byte_pos_str )
    byte_pos = Integer(byte_pos_str)
    bit_pos  = Integer(cell.bit_pos)
    size_in_bit = calc_cell_size_in_bit(cell)
    editor.set_val( @cell_val_cache[cell], cell.cell_type, byte_pos, bit_pos, size_in_bit )
  end

  def update_cell_cache( cell )
    if cell.kind_of?(Cell) then
      if base_type?(cell) then
        @cell_val_cache[cell] = (cell.val == '') ? 0 : cell.val
      else # value is not chaced for custom cells
        @cell_val_cache[cell] = nil
      end
    end
  end

  def _is_true(str)
    return true if str == true || str == 'true' || str == 'TRUE' || str == 't' || str == 'T'
    begin
      st = Integer(str)
    rescue
      return false
    end

    return true if st != 0

    return false
  end

end