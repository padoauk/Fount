# encoding: utf-8

=begin
 Copyright (c) 2013 ici@divagari.net All Rights Reserved
=end

require 'yaml'
require 'packet_db_manager'
require 'port_listener'

yml_fname = 'config/fount.yml'
begin
  conf = YAML.load_file(yml_fname)
rescue
  conf = YAML.new
end

PacketDatabaseManager.load(conf)

port_listener = PortListener.new(conf)
Thread.start do
  port_listener.go
end
