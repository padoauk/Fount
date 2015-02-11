# encoding: utf-8

=begin
 Copyright (c) 2013 Toshinao Ishii All Rights Reserved
=end

class CustomCellBase

  include BaseTypeCellUtil

  attr_reader :vals, :types, :sizes_in_bit, :size_total_in_bit, :num

  def initialize
    @sizes_in_bit = [8]
    @size_total_in_bit = 8
    @vals = [0]
    @types = ['C']
    @num = 1
    @editor = nil
  end

  def set_editor(editor)
    @editor = editor if editor.kind_of?(ByteArrayEditor)
  end

  def set_info(cell_info)
    @cell_info = cell_info
  end

  # To set an cell in a packet,
  #   ByteArrayEditor.set_val(val, type, byte_pos, bit_pos, size_in_bit)
  # can and should be called.
  # This base class provides, val, type and size_in_bit, but not byte_pos nor bit_pos.

  # CustomCell is, in general, sequence of cells of basic types
  def set_types(type_arr)
    @types = type_arr.dup
    @num = @types.length
    @size_total_in_bit = 0
    for i in 0 .. @num-1 do
      @sizes_in_bit[i] = size_in_bit_of_type(@types[i])
      @size_total_in_bit = @size_total_in_bit + @sizes_in_bit[i]
    end
  end

  def set_vals(val_arr)
    @vals = val_arr.dup
  end

  # template
  def calc
    # @vals is updated
  end

end