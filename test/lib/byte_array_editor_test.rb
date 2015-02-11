# encoding: utf-8

require 'test/unit'

require 'test/test_helper'
require 'lib/well/byte_array_editor'

class MyTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @byte_array_editor = ByteArrayEditor.new
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_set_byte_at
    # set value between 0 and 255
    p = 0
    v = 0
    @byte_array_editor.set_byte_at(p,v)
    assert_equal(@byte_array_editor.arr[p], v)

    p = 1
    v = 1
    @byte_array_editor.set_byte_at(p,v)
    assert_equal(@byte_array_editor.arr[p], v)

    p = 2
    v = 2
    @byte_array_editor.set_byte_at(p,v)
    assert_equal(@byte_array_editor.arr[p], v)

    p = 255
    v = 255
    @byte_array_editor.set_byte_at(p,v)
    assert_equal(@byte_array_editor.arr[p], v)

    p = 254
    v = 0xfe
    @byte_array_editor.set_byte_at(p,v)
    assert_equal(@byte_array_editor.arr[p], v)

    p = 253
    v = "0xfd"
    @byte_array_editor.set_byte_at(p,v)
    assert_equal(@byte_array_editor.arr[p], Integer(v))

    # unsigned
    assert_equal(@byte_array_editor.arr[3], nil)

    # set negative value
    p = 3
    v = -1
    @byte_array_editor.set_byte_at(p,v)
    assert_equal(@byte_array_editor.arr[p], 0)


    # set value more than 255 (0xff)
    p = 3
    v = 512
    @byte_array_editor.set_byte_at(p,v)
    assert_equal(@byte_array_editor.arr[p], 255)

    # return value
    assert_equal(0, @byte_array_editor.set_byte_at(5,0))
    assert_equal(0, @byte_array_editor.set_byte_at(5,255))
    assert_equal(-1, @byte_array_editor.set_byte_at(5,-1))
    assert_equal(1, @byte_array_editor.set_byte_at(5,256))

    # reset
    @byte_array_editor.reset
    assert_equal(@byte_array_editor.arr[0], nil)
  end

  def test_set_double_at

    @byte_array_editor.set_double_at(10, Math::E)
    arr = Array.new
    for i in 0..7 do
      arr[i] = @byte_array_editor.arr[10+i]
    end
    x = arr.pack('C*').unpack('G')
    assert_equal(x[0], Math::E)

    @byte_array_editor.set_float_at(20, Math::PI)
    arr = Array.new
    for i in 0..3 do
      arr[i] = @byte_array_editor.arr[20+i]
    end
    x = arr.pack('C*').unpack('g')
    assert_equal(true, (x[0]-Math::PI).abs < 0.00001)
  end

  def test_set_uint16_at
    # Fixnum
    m = @byte_array_editor.set_uint16_at(30, 0xabcd)
    assert_equal(0,m)
    arr = Array.new
    for i in 0..1 do
      arr[i] = @byte_array_editor.arr[30+i]
    end
    x = arr.pack('C*').unpack('n')
    assert_equal(0xabcd, x[0])

    # String
    @byte_array_editor.set_uint16_at(32, "0x01ff")
    arr = Array.new
    for i in 0..1 do
      arr[i] = @byte_array_editor.arr[32+i]
    end
    x = arr.pack('C*').unpack('n')
    assert_equal(0x01ff, x[0])

    @byte_array_editor.set_uint16_at(34, "43210")
    arr = Array.new
    for i in 0..1 do
      arr[i] = @byte_array_editor.arr[34+i]
    end
    x = arr.pack('C*').unpack('n')
    assert_equal(43210, x[0])

    # out of range
    m = @byte_array_editor.set_uint16_at(36, -1)
    assert_equal(-1, m)
    arr = Array.new
    for i in 0..1 do
      arr[i] = @byte_array_editor.arr[36+i]
    end
    x = arr.pack('C*').unpack('n')
    assert_equal(0, x[0])

    m = @byte_array_editor.set_uint16_at(36, 0x10000)
    assert_equal(1, m)
    arr = Array.new
    for i in 0..1 do
      arr[i] = @byte_array_editor.arr[36+i]
    end
    x = arr.pack('C*').unpack('n')
    assert_equal(0xffff, x[0])

  end

  def test_set_uint32_at
    upper = 3
    tplt = 'N'
    # Fixnum
    m = @byte_array_editor.set_uint32_at(40, 0xffffffff)
    assert_equal(0,m)
    arr = Array.new
    for i in 0..upper do
      arr[i] = @byte_array_editor.arr[40+i]
    end
    x = arr.pack('C*').unpack(tplt)
    assert_equal(0xffffffff, x[0])

    # String
    @byte_array_editor.set_uint32_at(42, "0xfedcba98")
    arr = Array.new
    for i in 0..upper do
      arr[i] = @byte_array_editor.arr[42+i]
    end
    x = arr.pack('C*').unpack(tplt)
    assert_equal(0xfedcba98, x[0])

    @byte_array_editor.set_uint32_at(44, "43210")
    arr = Array.new
    for i in 0..upper do
      arr[i] = @byte_array_editor.arr[44+i]
    end
    x = arr.pack('C*').unpack(tplt)
    assert_equal(43210, x[0])

    # out of range
    m = @byte_array_editor.set_uint32_at(46, -1)
    assert_equal(-1, m)
    arr = Array.new
    for i in 0..upper do
      arr[i] = @byte_array_editor.arr[46+i]
    end
    x = arr.pack('C*').unpack(tplt)
    assert_equal(0, x[0])

    m = @byte_array_editor.set_uint32_at(48, 0x100000000)
    assert_equal(1, m)
    arr = Array.new
    for i in 0..upper do
      arr[i] = @byte_array_editor.arr[48+i]
    end
    x = arr.pack('C*').unpack(tplt)
    assert_equal(0xffffffff, x[0])

  end

  def test_set_uint64_at
    upper = 7
    tplt = 'Q>'

    #                                          1 2 3 4 5 6 7 8
    m = @byte_array_editor.set_uint64_at(104,0xffffffffffffffff)
    assert_equal(0,m)
    arr = Array.new
    for i in 0..upper do
      arr[i] = @byte_array_editor.arr[104+i]
    end
    x = arr.pack('C*').unpack(tplt)
    assert_equal(0xffffffffffffffff, x[0])


    # underflow
    m = @byte_array_editor.set_uint64_at(112,-1)
    assert_equal(-1,m)
    arr = Array.new
    for i in 0..upper do
      arr[i] = @byte_array_editor.arr[112+i]
    end
    x = arr.pack('C*').unpack(tplt)
    assert_equal(0, x[0])

    # overflow
    #                                           1 2 3 4 5 6 7 8
    m = @byte_array_editor.set_uint64_at(120,0x10000000000000000)
    assert_equal(1,m)
    arr = Array.new
    for i in 0..upper do
      arr[i] = @byte_array_editor.arr[120+i]
    end
    x = arr.pack('C*').unpack(tplt)
    assert_equal(0xffffffffffffffff, x[0])

  end

  def test_set_int16_at
    upper = 1
    tplt = 's>'

    m = @byte_array_editor.set_int16_at(50,0x7fff)
    assert_equal(0,m)
    arr = Array.new
    for i in 0..upper do
      arr[i] = @byte_array_editor.arr[50+i]
    end
    x = arr.pack('C*').unpack(tplt)
    assert_equal(0x7fff, x[0])

    m = @byte_array_editor.set_int16_at(52,-0x7fff)
    assert_equal(0,m)
    arr = Array.new
    for i in 0..upper do
      arr[i] = @byte_array_editor.arr[52+i]
    end
    x = arr.pack('C*').unpack(tplt)
    assert_equal(-0x7fff, x[0])

    # underflow
    m = @byte_array_editor.set_int16_at(50,-0x8001)
    assert_equal(-1,m)
    arr = Array.new
    for i in 0..upper do
      arr[i] = @byte_array_editor.arr[50+i]
    end
    x = arr.pack('C*').unpack(tplt)
    assert_equal(-0x8000, x[0])

    # overflow
    m = @byte_array_editor.set_int16_at(52,0x8001)
    assert_equal(1,m)
    arr = Array.new
    for i in 0..upper do
      arr[i] = @byte_array_editor.arr[52+i]
    end
    x = arr.pack('C*').unpack(tplt)
    assert_equal(0x7fff, x[0])

  end

  def test_set_int32_at
    upper = 3
    tplt = 'l>'

    m = @byte_array_editor.set_int32_at(54,0x7fffffff)
    assert_equal(0,m)
    arr = Array.new
    for i in 0..upper do
      arr[i] = @byte_array_editor.arr[54+i]
    end
    x = arr.pack('C*').unpack(tplt)
    assert_equal(0x7fffffff, x[0])

    m = @byte_array_editor.set_int32_at(58,-0x7fffffff)
    assert_equal(0,m)
    arr = Array.new
    for i in 0..upper do
      arr[i] = @byte_array_editor.arr[58+i]
    end
    x = arr.pack('C*').unpack(tplt)
    assert_equal(-0x7fffffff, x[0])

    # underflow
    m = @byte_array_editor.set_int32_at(62,-0x80000001)
    assert_equal(-1,m)
    arr = Array.new
    for i in 0..upper do
      arr[i] = @byte_array_editor.arr[62+i]
    end
    x = arr.pack('C*').unpack(tplt)
    assert_equal(-0x80000000, x[0])

    # overflow
    m = @byte_array_editor.set_int32_at(66,0x80000001)
    assert_equal(1,m)
    arr = Array.new
    for i in 0..upper do
      arr[i] = @byte_array_editor.arr[66+i]
    end
    x = arr.pack('C*').unpack(tplt)
    assert_equal(0x7fffffff, x[0])

  end

  def test_set_int64_at
    upper = 7
    tplt = 'q>'

    m = @byte_array_editor.set_int64_at(72,0x7fffffffffffffff)
    assert_equal(0,m)
    arr = Array.new
    for i in 0..upper do
      arr[i] = @byte_array_editor.arr[72+i]
    end
    x = arr.pack('C*').unpack(tplt)
    assert_equal(0x7fffffffffffffff, x[0])

    m = @byte_array_editor.set_int64_at(80,-0x8000000000000000)
    assert_equal(0,m)
    arr = Array.new
    for i in 0..upper do
      arr[i] = @byte_array_editor.arr[80+i]
    end
    x = arr.pack('C*').unpack(tplt)
    assert_equal(-0x8000000000000000, x[0])

    # underflow
    m = @byte_array_editor.set_int64_at(88,-0x8000000000000001)
    assert_equal(-1,m)
    arr = Array.new
    for i in 0..upper do
      arr[i] = @byte_array_editor.arr[88+i]
    end
    x = arr.pack('C*').unpack(tplt)
    assert_equal(-0x8000000000000000, x[0])

    # overflow
    m = @byte_array_editor.set_int64_at(96,0x8000000000000000)
    assert_equal(1,m)
    arr = Array.new
    for i in 0..upper do
      arr[i] = @byte_array_editor.arr[96+i]
    end
    x = arr.pack('C*').unpack(tplt)
    assert_equal(0x7fffffffffffffff, x[0])

  end

  def test_bits_in_a_byte_at
    pos = 128

    @byte_array_editor.arr[pos] = 0
    bit_array = [1]
    v = 0
    for i in 0 .. 7 do
      v += 2**i
      @byte_array_editor.set_bits_in_a_byte_at(pos, i, bit_array)
      assert_equal(v, @byte_array_editor.arr[pos])
    end

    @byte_array_editor.arr[pos] = 0
    bit_array = [128]
    v = 0
    for i in 0 .. 7 do
      v += 2**i
      @byte_array_editor.set_bits_in_a_byte_at(pos, i, bit_array)
      assert_equal(v, @byte_array_editor.arr[pos])
    end

    @byte_array_editor.arr[pos] = 0
    bit_array = [-1024]
    v = 0
    for i in 0 .. 7 do
      v += 2**i
      @byte_array_editor.set_bits_in_a_byte_at(pos, i, bit_array)
      assert_equal(v, @byte_array_editor.arr[pos])
    end

    pos = 128
    @byte_array_editor.arr[pos] = 0
    bit_array = [1,0,1,0,1,0,1,0]
    @byte_array_editor.set_bits_in_a_byte_at(pos, 0, bit_array)
    assert_equal(2+8+32+128, @byte_array_editor.arr[pos])

    pos = 128
    @byte_array_editor.arr[pos] = 0
    bit_array = [1,1,0,1]
    @byte_array_editor.set_bits_in_a_byte_at(pos, 0, bit_array)
    assert_equal(8*1 +4*1 +2*0 +1*1, @byte_array_editor.arr[pos])

    # [1,1,0,1, 1]
    @byte_array_editor.set_bits_in_a_byte_at(pos, 1, bit_array)
    assert_equal(16*1 +8*1 +4*0 +2*1 +1*1, @byte_array_editor.arr[pos])
    # [1,1,0,1, 1,1]
    @byte_array_editor.set_bits_in_a_byte_at(pos, 2, bit_array)
    assert_equal(32*1 +16*1 +8*0 +4*1 +2*1 +1*1, @byte_array_editor.arr[pos])
    # [1,1,0,1, 0,1,1,1]
    @byte_array_editor.set_bits_in_a_byte_at(pos, 4, bit_array)
    assert_equal(128*1 +64*1 +32*0 +16*1 +8*0 +4*1 +2*1 +1*1, @byte_array_editor.arr[pos])

    begin
      @byte_array_editor.set_bits_in_a_byte_at(-1, 4, bit_array)
    rescue ParameterError => emsg
      assert_equal('pos out of range', emsg.to_s)
    end
    begin
      @byte_array_editor.set_bits_in_a_byte_at(0, 8, [])
    rescue ParameterError => emsg
      assert_equal('pos out of range', emsg.to_s)
    end
    begin
      @byte_array_editor.set_bits_in_a_byte_at(0, 4, 'Z')
    rescue ParameterError => emsg
      assert_equal('not Array', emsg.to_s)
    end
  end

  def test_bits_at

    pos = 136
    @byte_array_editor.arr[pos] = 0
    @byte_array_editor.arr[pos+1] = 0
    bit_array = [1,1,1,1,1,1,1,1,
                 0,0,0,0,0,0,0,1]
    @byte_array_editor.set_bits_at(pos, 0, bit_array)
    assert_equal(255, @byte_array_editor.arr[pos])
    assert_equal(  1, @byte_array_editor.arr[pos+1])

    @byte_array_editor.arr[pos] = 0
    @byte_array_editor.arr[pos+1] = 0
    @byte_array_editor.arr[pos+2] = 0
    bit_array = [1,1,1,1,1,1,1,1,
                 0,0,0,0,0,0,0,1,
                 1,1,0]
    @byte_array_editor.set_bits_at(pos, 0, bit_array)
    assert_equal(255, @byte_array_editor.arr[pos])
    assert_equal(  1, @byte_array_editor.arr[pos+1])
    assert_equal(  6, @byte_array_editor.arr[pos+2])

    @byte_array_editor.arr[pos-1] = 0
    @byte_array_editor.arr[pos] = 0
    bit_array = [1,1,0,0,1,1,1,1,
                 1,1,0,0]
    @byte_array_editor.set_bits_at(pos, -8, bit_array)
    assert_equal( 12, @byte_array_editor.arr[pos])
    assert_equal(128+64+8+4+2+1, @byte_array_editor.arr[pos-1])

    @byte_array_editor.arr[pos-1] = 0
    @byte_array_editor.arr[pos] = 0
    bit_array = [1,0,0,0,0,0,1,
                 1,1,0,0]
    @byte_array_editor.set_bits_at(pos, -7, bit_array)
    assert_equal(128+2, @byte_array_editor.arr[pos-1])  # [1,0,0,0,0,0,1, 0]
    assert_equal(12, @byte_array_editor.arr[pos])       # [0,0,0,0, 1,1,0,0]

    @byte_array_editor.arr[pos-1] = 0
    @byte_array_editor.arr[pos] = 0
    @byte_array_editor.arr[pos+1] = 0
    bit_array = [1,0,0,0,0,0,1,
                 1,0,0,0,0,0,0,1,
                 1,1,0,0]
    @byte_array_editor.set_bits_at(pos, -7, bit_array)
    assert_equal(128+2, @byte_array_editor.arr[pos-1])  # [1,0,0,0,0,0,1, 0]
    assert_equal(128+1, @byte_array_editor.arr[pos])    # [1,0,0,0,0,0,0,1]
    assert_equal(12, @byte_array_editor.arr[pos+1])     # [0,0,0,0, 1,1,0,0]

    @byte_array_editor.arr[pos] = 0
    @byte_array_editor.arr[pos+1] = 0
    bit_array = [1,1,0,1,
                 1,0,0]
    @byte_array_editor.set_bits_at(pos, 4, bit_array)
    assert_equal(128+64+16, @byte_array_editor.arr[pos])  # [1,1,0,1, 0,0,0,0]
    assert_equal(4, @byte_array_editor.arr[pos+1])  # [0,0,0,0,0,1,0,0]
  end

end