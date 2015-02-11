# encoding: utf-8

=begin
 Copyright 2014 Toshinao Ishii All Rights Reserved
=end


class PacketSegmentIntegrator

  include BaseTypeCellUtil

  def initialize(segments)

    set_segments(segments)

  end

  def set_segments(segments)
    if segments.kind_of?(Array) then
      @segments = segments
      set_byte_array
      @segments.each do |s|
        if s.kind_of?(Array)
          s.each do |c|
            update_cell(c)
          end
        end
      end
    else
      @segments = nil
      raise ParameterError, "#{__method__}"
    end
  end

   def update_cell(cell)
     # custom cells are updated in get_byte_array
     if base_type?(cell.cell_type) then
       update_base_type_cell(cell)
     end
   end

  def get_byte_array
    return @byte_arrays.dup
  end

  ####################################################
  private

  def set_byte_array

    # array of ByteArrayEditor or CustomCell each of which is associated to packet segments
    @byte_arrays = Array.new
    # map from cell of base type to its ByteArrayEditor
    @cell2editor = Hash.new
    for i in 0 .. (@segments.length-1) do
      if @segments[i].kind_of?(CustomCellBase)
        @byte_arrays[i] = @segments[i]
      else
        bae = ByteArrayEditor.new
        @segments[i].each do |c|
          @cell2editor[c] = bae
        end
        @byte_arrays[i] = bae
      end
    end

    fix_abbreviated

  end

  # fixe abbreviated byte_pos and size
  def fix_abbreviated

    # first, fix positions of base type cells
    @segments.each do |s|
      if s.kind_of?(Array) && 0 < s.length then
        # at the beginning of array s, c.byte_pos is defined explicitly
        c = s[0]
        next_byte_pos = Integer(c.byte_pos) + calc_cell_size_in_byte(c)

        # in the following cells
        for i in 1 .. (s.length-1) do
          c = s[i]

          # size
          if nil == c.size || 0 == c.size.length then
            c.size = calc_cell_size_in_byte(c).to_s
          end

          # byte pos
          if nil != c.byte_pos && 0 < c.byte_pos.length then
            next_byte_pos = Integer(c.byte_pos) + calc_cell_size_in_byte(c)
          else
            c.byte_pos = next_byte_pos.to_s
            next_byte_pos = next_byte_pos + calc_cell_size_in_byte(c)
          end

          c.save
        end
      end
    end

    # next, fix positions of custom cells
    @segments.each_index do |index|
      s = @segments[index]
      if s.kind_of?(CustomCellBase) then
        if nil == c.byte_pos || 0 == c.byte_pos.length then # position not defined
          if 0 == index then
            c.byte_pos = '0'
            c.save
          else
            s = @segments[index-1] # previous segment or custom cell
            if s.kind_of?(Array) then # segment
              # next to the last cell of the previous segment
              pcell = s.last # this must not be nil
              bp = Integer(pcell.byte_pos) + calc_cell_size_in_byte(pcell)
              c.byte_pos = bp.to_s
            else # custom cell

            end
          end
        end
      end
    end

  end

  def update_base_type_cell(cell)
    unless @cell2editor.has_key?(cell)
      raise ParameterError, "#{__method__} no such cell registered"
      return
    end

    # if cell is registered to an ByteArrayEditor, cell must be of base type
    byte_pos = Integer(cell.byte_pos)
    bit_pos  = Integer(cell.bit_pos)
    val      = (cell.val == '') ? 0 : cell.val
    type     = cell.cell_type
    # size supports in bits as well as in bytes
    size_str = cell.size
    size_unit_in_bit = 1                             # default in bits
    if size_str =~ /B$/ || size_str =~ /Byte$/ then  # in bytes with 'B' or 'Byte' at the end
      size_unit_in_bit = 8
      unless size_str.gsub!(/B$/,'')
        unless size_str.gsub!(/Byte$/,'')
          size_str.gsub!(/Bytes$/,'')
        end
      end
    end
    begin
      size_in_bit  = Integer(size_str) * size_unit_in_bit
    rescue => e
      raise ParameterError, "#{__method__} invalid size #{cell.size}"
    end

    puts "byte_pos: #{byte_pos}, bit_pos: #{bit_pos}, val: #{val}, type: #{type}, size: #{cell.size}"

    @cell2editor[cell].set_val(val, type, byte_pos, bit_pos, size_in_bit)

    return true
  end

end
