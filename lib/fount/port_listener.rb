# encoding: utf-8

=begin
 Copyright (c) 2013 Toshinao Ishii All Rights Reserved
=end

require 'logger'
require 'socket'

require 'padoauk'
require 'periodic_task'

class PortListener < PeriodicTask

  include PadoaukLog

  def initialize(conf)
    if conf.class != Hash then
      raise StandardError, 'no configuration setting'
      return
    end

    super()

    unless conf.key?('port') then
      raise StandardError, 'cannot find port number'
      return
    end
    @port = conf['port']

    # initial update period
    if conf.key?('period') then
      set_period(conf['period'])
    end

    # sever socket
    begin
      @server = TCPServer.open(@port)
    rescue
      raise IOError, "cannot open port #{@port.to_s}"
      return
    end

    @clients = Array.new
    _start_updates

  end

  # never returns
  def go
    loop do
      c = @server.accept
      @clients.push(c)
    end
  end


  def do_my_task(client)
    now = Time.now
    #      h   e   l   l   o      w   o   r   l   d   !
    #str = [104,101,108,108,111,32,119,111,114,108,100,33,32].pack("C*")
    #client.write str
    #client.write now.min.to_s + ":" + now.sec.to_s
    client.write "hello world !"
    client.flush
  end

  def send_stream(client, packet)
    nb = 0
    r0, t0 = Process.times, Time.now
    str = PacketManager.instance.get_stream(packet)
    if 0 < str.length
      begin
        client.write str
        client.flush
        nb = nb+1
      rescue => e
        raise ClientResponseError
      end
    end
    r1, t1 = Process.times, Time.now
    PadoaukLog.debug( cpu_usage(r0,r1,t0,t1), self, 0b00001000 ) if 0 < nb
  end

  ###############################################################
  private

  #
  # to be done in a dedicated thread
  #
  def _start_updates

    t = Thread.new do
      packet_manager = PacketManager.instance
      loop do
        # update pacekts
        list_updated = packet_manager.update_streams
        # send
        @clients.each_index do |i|
          c = @clients[i]
          list_updated.each do |p|
            begin
              send_stream(c, p)
            rescue => e
              @clients[i] = nil # to be removed
              PadoaukLog.info "terminated connection from #{c.peeraddr.to_s}", self
              c.close
              break # break list_updated.each
            end
          end
        end
        @clients.delete_if { |e| e == nil }

        Thread.stop
      end
    end

    add_task(t)

  end


  def is_true(str)
    return true if str == true || str == 'true' || str == 'TRUE' || str == 't' || str == 'T'
    begin
      st = Integer(str)
    rescue
      return false
    end

    return true if st != 0

    return false
  end

  def cpu_usage(r0,r1,t0,t1)
    utime = r1.utime - r0.utime
    stime = r1.stime - r0.stime
    dtime = t1 - t0
    str = 'utime: ' + utime.round(5).to_s + '  stime: ' + stime.round(5).to_s + '  duration: ' + dtime.round(5).to_s
  end

end
