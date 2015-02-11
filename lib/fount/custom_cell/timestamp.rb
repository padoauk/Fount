# encoding: utf-8

require 'custom_cell_base'

class Timestamp00 < CustomCellBase
  def initialize
    super
    #          YY   MM   DD   hh   mm   ss   ms
    set_types ['N', 'C', 'C','C', 'C', 'C', 'N']
    #           4  + 1  + 1 + 1  + 1  + 1  + 4 = 13
    set_vals [0,0,0,0,0,0,0]
  end

  def calc
    t = Time.now
    set_vals [
        t.year,
        t.mon,
        t.day,
        t.hour,
        t.min,
        t.sec,
        t.usec / 1000
             ]
  end


end