# encoding: utf-8

=begin
 Copyright (c) 2013 Toshinao Ishii All Rights Reserved
=end

require 'common'
require 'custom_cell_info'
require 'basetype_bytearray_editor'

class ByteArrayEditor

  include BaseTypeCellUtil
  include BasetypeByteArrayEditor

  def initialize
    @endian = :big
    reset
  end

  def reset
    @arr = Array.new
    @custom_cells = Array.new
  end

  def length
    return @arr.length
  end

  def byte_size
    return @arr.size
  end

  # for BasetypeByteArrayEditor
  def get_arr
    return @arr
  end

  # update custom cells and return the result
  def arr
    @custom_cells.each do |c|
      set_custom_cell_val(c)
    end
    @arr.map! { |x| (x == nil) ? 0 : x }
    @arr
  end

  def set_endian(endian)
    if endian == :big || endian == :little then
      @endia = endian
      return @endian
    end
    return false
  end

end
