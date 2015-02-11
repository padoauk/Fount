# encoding: utf-8

=begin
 Copyright (c) 2013 Toshinao Ishii All Rights Reserved
=end

require 'padoauk'
require 'common'
require 'cell_db_manager'

class PacketDatabaseManager

  def self.load(conf)
    if conf.class != Hash then
      raise StandardError, 'no configuration setting'
      return
    end
    
    # must have
    unless
        conf.key?('packet_name_space') ||
        conf.key?('packets')
    then
      return
    end


    # init_db ?
    if conf['init_db'] then
      init_db conf
    end

  end


  private

  def self.add(h)
    o = Packet.new(h)
    o.save
    return o
  end

  def self.delete_all
    Cell.delete_all
    Packet.delete_all
  end

  def self.init_db(conf)
    delete_all

    conf['packets'].each do |p|
      # suppose p is
      #   [1, {"name_space"=>"xxx", "name"=>"yyy", ... } ]
      pdef = p[1]
      h = Hash.new
      h[:name_space] = conf['packet_name_space'];
      h[:name] = pdef['name'];
      h[:version] = pdef['version'];
      h[:is_active] = pdef.key?('is_active') ? pdef['is_active'] : false
      h[:period] = pdef.key?('period') ? pdef['period'] : 1000
      p = add(h)
      begin
        CellDatabaseManager.load(pdef['cell_csv'], p)
      rescue CSVLoadError => e
        puts "#{pdef['cell_csv']} has some format error\n";
        return
      end
    end
  end

end

