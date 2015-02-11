# encoding: utf-8

require 'custom_cell_base'

#
# total size of packet
#
class ByteSize16 < CustomCellBase
  def initialize
    super               # requirement 1-1)
    set_types(['n'])    # requirement 1-2)
    set_vals([0])
  end

  def calc
    sz = @editor.byte_size
    if 0xffff < sz then
      sz = 0xfffff
      raise ValueError, "#{self.class.name}.#{__method__} byte array size exceeds 16 bit"
    end
    set_vals([sz])    # requirement 2-1)
  end

end