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

#
# variable size custom cell
#
class VarSizeTest < CustomCellBase
  MaxSer = 2**32
  Mod = 4
  def initialize
    super               # requirement 1-1)
    @ser = 0
    set_types(['C'])    # requirement 1-2)
    set_vals([@ser])
  end

  def calc
    m = @ser % Mod
    varr = []
    tarr = []
    for i in 0 .. m do
      varr[i] = (@ser + 100) % 256
      tarr[i] = 'C'
    end
    set_vals(varr)   # requirement 2-1)
    set_types(tarr)  # requirement 1-1)

    @ser = @ser + 1
    @ser = 0 if @ser == MaxSer
  end

end