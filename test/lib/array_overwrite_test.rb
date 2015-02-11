# encoding: utf-8

require 'test/unit'
require 'lib/fount/common'

class MyTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_stretch
    len = 5
    a0 = Array.new(len){|i| i}
    a1 = a0.stretch(0)
    assert_equal(a0,a1)
    a1 = a0.stretch(a0.length)
    assert_equal(a0,a1)

    a1 = a0.stretch(a0.length * 2)
    assert_equal(a1.length, len*2)
    assert_equal(a1[len],nil)
    assert_equal(a1[len*2-1],nil)
  end

  def test_stretch_slice
    len = 5
    a0 = Array.new(len){|i| i}
    r = 0 .. len-1
    a1 = a0.stretch_slice(r)
    assert_equal(a0, a1)

    r = 1 .. len-2
    a2 = a0.stretch_slice(r)
    a3 = a0.slice(r)
    assert_equal(a2, a3)

    r = 0 .. len
    a4 = a0.stretch_slice(r)
    assert_equal(a4.length, len+1)
    assert_equal(a4[len+1], nil)

    r = 2 .. len+2
    a5 = a0.stretch_slice(r)
    puts "a5: " + a5.to_s
    assert_equal(a5.length, len+1)
    assert_equal(a5[0], a0[2])
    assert_equal(a5[a5.length-1], nil)
    assert_equal(a5[a5.length-2], nil)
    assert_equal(a5[a5.length-3], nil)
  end

  def test_embed
    puts 'test_embed'
    len = 5
    a0 = Array.new(len){|i| i}
    a1 = Array.new(len){|i| i+10}

    b1 = a0.embed(a1, 0)
    puts 'b1: ' + b1.to_s
    assert_equal(b1.length, a0.length+a1.length)
    assert_equal(b1[0],a1[0])
    assert_equal(b1[a1.length],a0[0])

    b2 = a0.embed(a1, 2)
    puts 'b2: ' + b2.to_s
    assert_equal(b2.length, a0.length+a1.length)
    assert_equal(b2[0],a0[0])
    assert_equal(b2[2],a1[0])
    assert_equal(b2[2+a1.length], a0[2])
  end

  def test_overwrite
    puts 'test_overwrite'
    len = 5
    a0 = Array.new(len){|i| i}
    a1 = Array.new(len){|i| i+10}

    b1 = a0.overwrite(a1,0)
    puts 'b1: ' + b1.to_s
    assert_equal(a1, b1)

    b2 = a0.overwrite(a1,2)
    puts 'b2: ' + b2.to_s
    assert_equal(b2.length,len+2)
    assert_equal(b2[1], a0[1])
    assert_equal(b2[2], a1[0])

    b3 = a0.overwrite(a1, a0.length)
    puts 'b3: ' + b3.to_s
    assert_equal(b3[len-1], a0[len-1])
    assert_equal(b3[len], a1[0])
    assert_equal(b3[b3.length-1], a1[a1.length-1])

    b4 = a0.overwrite(a1, a0.length+1)
    puts 'b4: ' + b4.to_s
    assert_equal(b4[len-1], a0[len-1])
    assert_equal(b4[len], nil)
    assert_equal(b4[len+1], a1[0])
    assert_equal(b4[b4.length-1], a1[a1.length-1])
  end

end