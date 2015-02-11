# encoding: utf-8

=begin
 Copyright (c) 2013 Toshinao Ishii All Rights Reserved
=end

require 'csv'
require 'common'
require 'padoauk'

class CellDatabaseManager

  def self.load(file_name, packet)
    insert_load(file_name, packet, 0)
  end

  private

  def self.insert_load(file_name, packet, seq)
    CSV.foreach(file_name) do |row|
      begin
        next if row.length == 0
        # Comment:
        next if row[0].match(/^#/)
        # PacketID:
        if row[0].match(/^!/) then # Name of packet
          nm = row[0].sub(/^!\s*/, '')
          nm = nm.sub(/\s*$/, '')
          unless ( nm == packet.name ) then
            raise CSVLoadError, "#{nm} is not packet.name: #{packet.name}"
          end
          next
        end
        # Include file
        if row[0].match(/^</)
          wds = row[0].split(/\s+/)
          if wds[1]
            seq = insert_load(wds[1], packet, seq)
          end
          next
        end
        # ValueLine:
        unless 5 <= row.length then
          PadoaukLog.warn "warn #{row.join(',').to_s} skipped", self
          next
        end
        c = Hash.new
        c[:name] = chop(row[0])
        c[:cell_type] = chop(row[1])
        c[:seq] = seq; seq = seq +1
        c[:size] = chop(row[2])
        # byte_pos is string since it may be '..'
        c[:byte_pos] = chop(row[3])
        # for bit_pos, nil means 0
        c[:bit_pos]  = chop(row[4]).to_i
        if 6 <= row.length then
          c[:val] = chop(row[5])
        else
          c[:val] = ''
        end
        c[:packet_id] = packet.id
        add(c)
      rescue => e
        PadoaukLog.error "error  #{row.join(',').to_s} #{e.to_s}", self
      end
    end

    return seq
  end


  def self.add(h)
    puts "save: " + h.to_s
    o = Cell.new(h)
    o.save
    return o
  end

  def self.chop(str)
    return "" if str == nil
    str = str.sub(/^\s+/,'');
    str = str.sub(/\s+$/,'');
    str
  end
end

