# encoding: utf-8

=begin
 Copyright (c) 2013 Toshinao Ishii All Rights Reserved
=end

require 'require_all'

#
# CustomCellInfo is working environment of custom cell. Custom cells are minimum objects that
# knows just its internal format and value calculation method.
#
class CustomCellInfo
  attr_reader :type,:byte_pos,:bit_pos,:cell
  @@path = 'lib/fount/custom_cell'

  def initialize(type, byte_pos, bit_pos)
    # environment
    @type = type
    @byte_pos = byte_pos
    @bit_pos = bit_pos
    # custom cell
    begin
      @cell = create_cell type
      # cell's ref to its env
      @cell.set_info self
    rescue => e
      puts 'custom cell error: ' + e.to_s
    end
  end

  def self.set_path(path)
    @@path = path
  end

  private

  def create_cell(type)
    begin
      require_all @@path
    rescue  => e
      puts "#{__method__} " + e.to_s
    end

    unless Module.const_defined?(type) then
      raise InvalidCustomCell, "#{type} no such class"
    end
    cc = Module.const_get(type)
    unless cc.method_defined?(:calc) then
      raise InvalidCustomCell, "#{type} has no method of calc"
    end

    return cc.new
  end
end