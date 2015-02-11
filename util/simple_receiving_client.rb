#!/usr/bin/env ruby
# encoding: utf-8

require 'socket'      # Sockets are in standard library

host = 'localhost'
port = 2000

host = ARGV[0] if 0 < ARGV.length
port = ARGV[1] if 1 < ARGV.length

s = TCPSocket.open(host, port)

while msg = s.recv(1024)
  break if msg.length <= 0
  puts msg.unpack('C*').to_s
end
s.close
