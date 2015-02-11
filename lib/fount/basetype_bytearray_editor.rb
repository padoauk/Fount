# encoding: utf-8

=begin
 Copyright (c) 2013 Toshinao Ishii All Rights Reserved
=end

require 'common'
require 'padoauk'

#
# assuming ...
#   @endian which has endian specification
#   get_arr, method defined in class, returns editing byte array
#
module BasetypeByteArrayEditor

  include ByteBitArray

  # size_in_bit is necessary only for type: 'C' and type: 'B'
  def set_val(val, type, byte_pos, bit_pos, size_in_bit=0)

    if type == 'C' then
      if size_in_bit <= 0 || size_in_bit % 8 != 0 then
        raise ParameterError, "#{__method__} invalid size #{size_in_bit}"
      end
      size_in_byte = size_in_bit / 8
      arr = to_multi_byte(val, size_in_byte)
      for i in 0 .. size_in_byte-1 do
        set_byte_at(byte_pos+i, arr[i])
      end
    elsif type == 'n' then
      set_uint16_at(byte_pos, val)
    elsif type == 'N' then
      set_uint32_at(byte_pos, val)
    elsif type == 's>' then
      set_int16_at(byte_pos, val)
    elsif type == 'l>' then
      set_int32_at(byte_pos, val)
    elsif type == 'q>' then
      set_int64_at(byte_pos, val)
    elsif type == 'g' then
      set_float_at(byte_pos, val)
    elsif type == 'G' then
      set_double_at(byte_pos, val)
    elsif type == 'B' then
      if size_in_bit <= 0 then
        raise ParameterError, "#{__method__} invalid size #{size_in_bit}"
      end
      arr = to_multi_bit(val, size_in_bit)
      set_bits_at(byte_pos, bit_pos, arr)
    else
      raise ParameterError, "#{__method__} unknown cell type #{type}"
    end

  end


  # a byte data
  def set_byte_at(pos, val)
    # pmt validation
    p = validate_pos(pos)
    raise ParameterError if p < 0
    begin
      x = (val.kind_of?(Integer)) ? val : Integer(val)
    rescue
      raise ParameterError, "#{__method__} val is not Integer"
    end

    # core
    is_modified = 0
    if x < 0 then
      x = 0
      is_modified = -1
    elsif 255 < x then
      x = 255
      is_modified = 1
    end

    if is_modified != 0
      PadoaukLog.warn "#{val} is modified to #{x}", self
    end

    _arr = get_arr
    _arr[p] = x

    return is_modified
  end

  # unsigned integers

  def set_ushort_at(pos,val)
    return set_uint16_at(pos, val)
  end

  def set_uint16_at(pos,val)
    t = (@endian == :big) ? 'n' : 'v'
    return set_rb_uint_at(pos, val, t)
  end

  def set_uint32_at(pos,val)
    t = (@endian == :big) ? 'N' : 'v'
    return set_rb_uint_at(pos, val, t)
  end

  def set_uint64_at(pos,val)
    t = (@endian == :big) ? 'Q>' : 'Q<'
    return set_rb_uint_at(pos, val, t)
  end

  # signed integers

  def set_short_at(pos,val)
    return set_set_int_at(pos, val)
  end

  def set_int16_at(pos,val)
    t = (@endian == :big) ? 's>' : 's<'
    return set_rb_int_at(pos, val, t)
  end

  def set_int32_at(pos,val)
    t = (@endian == :big) ? 'l>' : 'l<'
    return set_rb_int_at(pos, val, t)
  end

  def set_int64_at(pos,val)
    t = (@endian == :big) ? 'q>' : 'q<'
    return set_rb_int_at(pos, val, t)
  end

  # float(32bit) and double(64bit)
  def set_double_at(pos, val)
    t = (@endian == :big) ? 'G' : 'E'
    return set_rb_float_at(pos, val, t)
  end

  def set_float_at(pos, val)
    t = (@endian == :big) ? 'g' : 'e'
    return set_rb_float_at(pos, val, t)
  end

  # bits
=begin

  set_bits_in_a_byte_at(byte_pos, bit_pos, bit_array)

  range of bit_pos is between 0 and 7

  suppose
    @arr[byte_pos] => Integer( '0b' + [b7,b6,b5,b4,b3,b2,b1,b0].join )
  where bN = 0 or 1 (N = 0..7) and
    bit_array => [aM, ..., a0]
  where 0 <= M <= 7

  set_bits_at() replaces @arr[byte_pos] to
    Integer( '0b' + barr.join )
  where
    barr => [b7, b6, aM, ... a0, b1, b0]
  for the above barr to be valid, it must be
    bit_array.length + bit_pos <= 8  notice in barr position of aM is
    8 - (bit_array.length + bit_pos)
  e.x.
    7 in case bit_pos == 0 and bit_array.length == 1    [ x, x, x, x, x, x, x,a0]
    6 in case bit_pos == 0 and bit_array.length == 2    [ x, x, x, x, x, x,a1,a0]
    6 in case bit_pos == 1 and bit_array.length == 1    [ x, x, x, x, x, x,a0, x]
    0 in case bit_pos == 7 and bit_array.length == 1    [a0, x, x, x, x, x, x, x]
    0 in case bit_pos == 6 and bit_array.length == 2    [a1,a0, x, x, x, x, x, x]

=end
  # 0 <= byet_pos, 0 <= bit_pos and bit_array.length + bit_pos <= 8 must be satisfied
  def set_bits_in_a_byte_at(byte_pos, bit_pos, bit_array)
    byte_pos = byte_pos.kind_of?(Integer) ? byte_pos : Integer(byte_pos)
    bit_pos  = bit_pos.kind_of?(Integer) ? bit_pos : Integer(bit_pos)
    raise ParameterError, "#{__method__} not Array" unless bit_array.kind_of?(Array)
    raise ParameterError, "#{__method__} pos out of range" if byte_pos < 0 || bit_pos < 0 || 8 < bit_array.length + bit_pos

    return if bit_array.length == 0

    _arr = get_arr

    x = (_arr[byte_pos] == nil) ? 0 : _arr[byte_pos]
    # barr is array of size 8 whose elements are 0 or 1
    barr = [x].pack('C').unpack('B8')[0].split(//).map{ |v| zero_or_one(v) }
    sarr = bit_array.map{ |v| zero_or_one(v) }
    offset = 8-(bit_pos+sarr.length)
    (0 .. sarr.length - 1).each { |i|
      barr[offset+i] = sarr[i]
    }
    _arr[byte_pos] = Integer( '0b' + barr.join )
  end

  # 0 <= byte_pos and 0 <= pos_byte * 8 + bit_pos must be satisfied
  def set_bits_at(byte_pos, bit_pos, bit_array)
    byte_pos = byte_pos.kind_of?(Integer) ? byte_pos : Integer(byte_pos)
    bit_pos  = bit_pos.kind_of?(Integer) ? bit_pos : Integer(bit_pos)
    raise ParameterError, "#{__method__} not Array" unless bit_array.kind_of?(Array)
    raise ParameterError, "#{__method__} pos out of range" if byte_pos < 0 || bit_pos + byte_pos * 8 < 0

    return if bit_array.length == 0

    # already "normalized" so that set_bits_in_a_byte_at() is ready to operate
    if 0 <= bit_pos && bit_array.length + bit_pos <= 8 then
      return set_bits_in_a_byte_at(byte_pos, bit_pos, bit_array)
    end

    # normalize bit_pos and byte_pos
    byte_shift = bit_pos / 8  # notice -1/8 => -1, 1/8 => 0, 9/8 => 1
    bit_pos_normalized  = bit_pos - 8 * byte_shift # between 0 and 7
    byte_pos_normalized = byte_pos + byte_shift
    ## byte_pos_normalized and bit_pos_normalized are final
    raise ParameterError, "#{__method__} pos out of range" if byte_pos_normalized < 0
    if bit_array.length + byte_pos_normalized <= 8 then
      return set_bits_in_a_byte_at(byte_pos_normalized, bit_pos_normalized, bit_array)
    end

    # normalize bit_array
    r = 0 # last result
    ## less than 8bits first byte
    bit_array_after = bit_array
    if 0 < bit_pos_normalized then
      # ex) if bit_pos == 1 then array[0,6] to be set in the byte
      r = set_bits_in_a_byte_at(byte_pos_normalized, bit_pos_normalized, bit_array_after[0..(7-bit_pos_normalized)])
      #
      bit_array_after = bit_array_after[8-bit_pos_normalized .. -1]
      byte_pos_normalized += 1
    end
    ## inbetween bytes
    (0..((bit_array_after.length)/8-1)).each { |i|
      p = byte_pos_normalized + i
      a = bit_array_after[(i*8) .. (i*8+7)]
      r = set_bits_in_a_byte_at(p, 0, a)
    }
    ## last byte
    mod = (bit_array_after.length) % 8
    if 0 == mod then
      return r
    elsif 0 < mod then
      mag = (bit_array_after.length)/8
      p = byte_pos_normalized + mag
      a = bit_array_after[mag*8..-1]
      return set_bits_in_a_byte_at(p,0,a)
    end

    # finished in any case above this
    raise ParameterError, "#{__method__} something wrong"
  end

  #################################################################
  private

  def zero_or_one(v)
    return 0 if v == nil
    v = ( v.kind_of?(Integer) ) ? v : Integer(v)
    return 0 if v == 0
    return 1
  end

  def validate_pos(pos)
    p = pos.kind_of?(Integer) ? pos : Integer(pos)

    return p
  end

  # floating point number
  def set_rb_float_at(pos, val, float_template)
    # pmt validation
    p = validate_pos(pos)
    raise ParameterError, "#{__method__} pos is negative" if p < 0
    begin
      x = (val.kind_of?(Float)) ? val : Float(val)
    rescue
      raise ParameterError, "#{__method__} val is not Float"
    end

    # core
    edit(p,x,float_template)

    return 0
  end

  # unsigned integer
  def set_rb_uint_at(pos, val, template)
    return false unless
        template == 'n' || template == 'N' ||
            template == 'v' || template == 'V' ||
            template == 'Q>' || template == 'Q<'
    maxval = 0xffff
    if template == 'N' || template == 'V' then
      maxval = 0xffffffff
    elsif template == 'Q>' || template == 'Q<'
      #          1 2 3 4 5 6 7 8
      maxval = 0xffffffffffffffff
    end

    # pmt validation
    p = validate_pos(pos)
    raise ParameterError, "#{__method__} pos is negative" if p < 0
    begin
      x = (val.kind_of?(Integer)) ? val: Integer(val)
    rescue
      raise ParameterError , "#{__method__} val is not Integer"
    end

    is_modified = 0
    if x < 0 then
      x = 0
      is_modified = -1
    elsif maxval < x then
      x = maxval
      is_modified = 1
    end

    if is_modified != 0
      PadoaukLog.warn "#{val} is modified to #{x}", self
    end

    edit(p, x, template)

    return is_modified
  end

  # signed integer
  def set_rb_int_at(pos, val, template)
    return false unless
        template == 's>' || template == 'l>' || template == 'q>' ||
            template == 's<' || template == 'l<' || template == 'q<'
    maxval =  0x7fff
    minval = -0x8000
    if template == 'l>' || template == 'l<' then
      #           1 2 3 4
      maxval =  0x7fffffff
      minval = -0x80000000
    elsif template == 'q>' || template == 'q<'
      #           1 2 3 4 5 6 7 8
      maxval =  0x7fffffffffffffff
      minval = -0x8000000000000000
    end

    # pmt validation
    p = validate_pos(pos)
    raise ParameterError, "#{__method__} pos is negative" if p < 0
    begin
      x = (val.kind_of?(Integer)) ? val: Integer(val)
    rescue
      raise ParameterError, "#{__method__} val is not Integer"
    end

    is_modified = 0
    if x < minval then
      x = minval
      is_modified = -1
    elsif maxval < x then
      x = maxval
      is_modified = 1
    end

    if is_modified != 0
      PadoaukLog.warn "#{val} is modified to #{x}", self
    end

    edit(p,x,template)

    return is_modified
  end

  def edit(pos, val, template)
    _arr = get_arr
    a = [val].pack(template).unpack('C*')
    (0..a.size-1).each { |i|
      _arr[pos+i] = a[i]
    }
  end

end