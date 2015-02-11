# encoding: utf-8

=begin
 Copyright (c) 2013 Toshinao Ishii All Rights Reserved
=end

require 'padoauk'

class PeriodicTask

  include PadoaukLog

  def initialize
    @period = 3 # sec
    @pause = false
    @task_threads = Array.new
    @mutex = Mutex.new
    schedule
  end

  def schedule
    Thread.start do
      loop {
        @task_threads.each { |t|
          if t.alive? && t.stop? then
            t.run
          end
        }
        sleep @period
      }
    end
  end

  def set_period(p)
    @period = p.to_i
  end

  def pause
    @pause = true
  end

  def start
    @pause = false
  end

  #
  # add a Thread instance which stops automatically, like the following, when a period of task is finished
  #
  #    t = Thread.new do
  #       loop do {
  #          #task execution
  #          Thread.stop
  #       }
  #    end
  #
  def add_task(t)
    #if t.instanceof?(Thread) then
    if t.class == Thread then
      begin
        t.stop
      rescue
      end
      @task_threads.push(t)
      PadoaukLog.info "task added. #tasks: #{@task_threads.length.to_s}", self
      return true
    end

    PadoaukLog.warn "#{t.class.name} is not a Thread", self
    return false
  end

  def remove_task(t)
    @task_threads.delete(t)
    PadoaukLog.info "task removed remove. #tasks: #{@task_threads.length.to_s}", self
  end

end
