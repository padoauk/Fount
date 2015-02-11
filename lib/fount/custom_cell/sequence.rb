# encoding: utf-8

=begin

  CustomCell requirements:
    1) in initialize
    1-1)  invoke super
    1-2)  invoke set_types and provide basic types in Array
    2) in calc
    2-1)  invoke set_vals  and provide values in Array
    3) Array lengths provided to set_types and set_vals must be same.

=end
require 'custom_cell_base'

class Sequence32Cell < CustomCellBase
  MaxSer = 2**32
  def initialize
    super               # requirement 1-1)
    @ser = 0
    set_types(['N'])    # requirement 1-2)
    set_vals([@ser])
  end

  def calc
    set_vals([@ser])    # requirement 2-1)

    @ser = @ser + 1
    @ser = 0 if @ser == MaxSer
  end

end