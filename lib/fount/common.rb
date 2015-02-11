# encoding: utf-8

=begin
 Copyright (c) 2013 Toshinao Ishii All Rights Reserved
=end

#
# Exceptions
#
class ParameterError < StandardError; end
class CSVLoadError < StandardError; end
class InvalidCustomCell < StandardError; end
class ValueError < StandardError; end
class ClientResponseError < StandardError; end


############################################################
# adding methods to Array
############################################################
## stretch(len) ##
# a = Array.new(5) {|i| i} => [0,1,2,3,4]
# a.stretch(7)             => [0,1,2,3,4,nil,nil]
# a                        => [0,1,2,3,4]
# a.stretch!(7)            => [0,1,2,3,4,nil,nil]
# a                        => [0,1,2,3,4,nil,nil]
#
## stretch_slice(range) ##
# a = Array.new(5) {|i| i} => [0,1,2,3,4]
# a.slice(2..6) => []      =>     [2,3,4]
# a.stretch_slice (2..6)   =>     [2,3,4,nil,nil]
# a                        => [0,1,2,3,4]
#
## embed(arr, index) ##
# a = Array.new(3) {|i| i}    => [0,1,2]
# b = Array.new(3) {|i| i+10} => [10,11,12]
# a.embed(b,1)                => [0,10,11,12,1,2]
# a.embed(b,4)                => [0,1,2,nil,10,11,12]
# a                           => [0,1,2]
#
## overwrite(arr, index) ##
# a = Array.new(6) {|i| i}    => [0,1,2,3,4,5]
# b = Array.new(3) {{i} i+10} => [10,11,12]
# a.overwrite(b,2)            => [0,1,10,11,12,5]
# a.overwrite(b,8)            => [0,1,2,3,4,5,nil,nil,10,11,12]
# a                           => [0,1,2,3,4,5]
############################################################
class Array

  def stretch_slice (opt)
    if opt.kind_of?(Range)
      arr = Array.new(self)
      arr.stretch!(opt.last+1)
    end
    arr.slice(opt)
  end

  def stretch (len)
    arr = Array.new(self)
    arr.stretch!(len)
    return arr
  end

  def stretch!(len)
    unless len.kind_of?(Fixnum) then
      return self
    end

    if 0 < len - self.length then
      self[len-1] = nil
    end
    return self
  end

  def embed(arr, pos)
    unless arr.kind_of?(Array) && pos.kind_of?(Fixnum) && 0 <= pos
      return nil # nothing can be done to make new array. therefore returns nothing
    end

    if pos == 0
      return arr + Array.new(self)
    end

    a0 = self.stretch_slice(0..pos-1) + arr
    if pos <= self.length-1
      a0 = a0 + self.stretch_slice(pos .. self.length-1)
    end
    return a0
  end

  def overwrite(arr,pos)
    unless arr.kind_of?(Array) && pos.kind_of?(Fixnum) && 0 <= pos
      return Array.new(self) # nothing can be done to overwrite array. therefore returns copy of original
    end

    a0 = Array.new(0)
    if 0 < pos
      a0 = self.stretch_slice(0..pos-1) + arr
    elsif 0 == pos
      a0 = Array.new(arr)
    end
    ovw_start = pos+arr.length
    ovw_end   = self.length-1
    if ovw_start <= ovw_end
      a0 = a0 + self.slice(ovw_start .. ovw_end)
    end
    return a0
  end

end

####
module ByteBitArray

  # Convert value to byte array
  #   to_multi_byte( '0xaabbcc' )     => [0xaa, 0xbb, 0xcc]
  #   to_multi_byte( '0xaabbcc', 4 )  => [0xaa, 0xbb, 0xcc, 0]
  #   to_multi_byte( '0xaabbcc', 3 )  => [0xaa, 0xbb]
  #   to_multi_byte( '0x00aabbcc' )   => [0xaa, 0xbb, 0xcc]
  #   to_multi_byte( '' )             => [0]        # null string is equivalent to 0
  def to_multi_byte( val, array_size=-1 )
    array_size = Integer(array_size) unless array_size.kind_of?(Integer)
    if val == '' then
      val = '0'
    end
    # convert val to hex string representation
    begin
      val = Integer(val).to_s(16)
    rescue => e
      raise ParameterError, "#{__method__} contains invalid string for number"
    end

    val = '0' + val if (val.length % 2) == 1

    arr =  val.scan(/../).map{ |b| b.to_i(16) }
    return arr if array_size < 0
    return _fit_array_length( arr, array_size )
  end

  # Convert value to bit array
  #   to_multi_bit( '0b101010',  6 )  =>  [1,0,1,0,1,0]
  #   to_multi_bit( '0b101010',  10 ) =>  [1,0,1,0,1,0,0,0,0,0]
  #   to_multi_bit( '0b101010',  3  ) =>  [1,0,1]
  #   to_multi_bit( '0b01010' )       =>  [1,0,1,0]  # minimum array size for val
  #   to_multi_bit( '' )              =>  [0]        # null string is equivalent to 0
  def to_multi_bit( val, array_size=-1 )
    array_size = Integer(array_size) unless array_size.kind_of?(Integer)
    if val == '' then
      val = '0'
    end
    begin
      val = Integer(val).to_s(2)
    rescue => e
      raise ParameterError, "#{__method__} contains invalid string for number"
    end

    arr =  val.scan(/./).map{ |b| b.to_i(2) }
    return arr if array_size < 0
    return _fit_array_length( arr, array_size )
  end

  private

  def _fit_array_length( arr, size )
    brr = arr.dup
    if arr.size == size then
      return brr
    end

    if arr.size < size then
     for i in 1 .. size-arr.size do
       brr.push(0)
     end

     return brr
    end

    for i in 1 .. arr.size - size do
      brr.pop
    end

    return brr

  end
end

module BaseTypeCellUtil
  def base_type?(type)
    if type.kind_of?(Cell) then
      type = type.cell_type
    end
    return true if
        type == 'C' || type == 'n' || type == 'N' || type == 's>' ||
            type == 'l>' || type == 'q>' || type == 'g' || type == 'G' || type == 'B'
    return false
  end

  def size_in_byte_of_type(type)
    return 1 if type == 'C' || type == 'B'
    return 2 if type == 'n' || type == 's>'
    return 4 if type == 'N' || type == 'l>' || type == 'g'
    return 8 if type == 'q>' || type == 'G'
    raise ParameterError, "#{__method__} unknown type"
    return 0
  end

  def size_in_bit_of_type(type)
    return  1 if type == 'B'
    return  8 if type == 'C'
    return 16 if type == 'n' || type == 's>'
    return 32 if type == 'N' || type == 'l>' || type == 'g'
    return 64 if type == 'q>' || type == 'G'
    raise ParameterError, "#{__method__} unknown type"
    return 0
  end

  def str2cell_size_in_bit(size_str)
    unless size_str.kind_of?(String)
      raise ParameterError, "#{__method__} invalid size #{size_str}"
      return 0
    end
    return 0 if 0 == size_str.length

    size_unit_in_bit = 1                             # default in bits
    if size_str =~ /B$/ || size_str =~ /Byte$/ then  # in bytes with 'B' or 'Byte' at the end
      size_unit_in_bit = 8
      unless size_str.gsub!(/B$/,'')
        unless size_str.gsub!(/Byte$/,'')
          size_str.gsub!(/Bytes$/,'')
        end
      end
    end
    size_in_bit  = Integer(size_str) * size_unit_in_bit
    return size_in_bit
  end

  def str2cell_size_in_byte(size_str)
    bits = str2cell_size_in_bit_from_str(size_str)
    bytes = (bits / 8.0).ceil
    return bytes
  end

  def calc_cell_size_in_byte(cell)
    sz_in_byte = str2cell_size_in_byte(c.size)
    if 0 == sz_in_byte then
      sz_in_byte = size_in_byte_of_type(c.cell_type)
    end
    return sz_in_byte
  end

  def calc_cell_size_in_bit(cell)
    size_in_bit = str2cell_size_in_bit(cell.size)
    if 0 == size_in_bit then
      size_in_bit = size_in_bit_of_type(cell.cell_type)
    end
    return size_in_bit
  end

end

# class_exsits?("String") => ture
# class_exists?("djfakf20dak") => false
def class_exists?(classname)
  str = classname.to_s
  eval("defined?(#{str}) && #{str}.is_a?(Class)") == true
end
