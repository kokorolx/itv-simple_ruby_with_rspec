# frozen_string_literal: true

require 'pry'
require_relative './constants.rb'

class Array
  def index_by
    if block_given?
      result = {}
      each { |elem| result[yield(elem)] = elem }
      result
    else
      to_enum(:index_by) { size if respond_to?(:size) }
    end
  end
end

class Checkout
  include Constants
  attr_accessor :promotional_rules
  attr_accessor :scan_items, :loaded_data, :loaded_data_as_hash, :number_items

  def initialize(promotional_rules = '')
    @loaded_data = SAMPLE_DATA
    @loaded_data_as_hash = @loaded_data.index_by { |item| item[:code] }
    @scan_items = []
    @promotional_rules = promotional_rules.split(',')
    @number_items = {}
  end

  def scan(item_code)
    @scan_items << item_code
  end

  def total
    return 0 unless promotions_valid?
    return total_cost if promotional_rules.empty?
    return total_with_1_promotion if promotional_rules.length == 1

    total_discount_by_cost(total_discount_by_number_item).round(2)
  end

  private

  def promotion_valid?(promo_code)
    !PROMOTIONAL_RULES[promo_code.strip.to_sym].nil?
  end

  def promotions_valid?
    return true if @promotional_rules.empty?

    !promotional_rules.map { |promo_code| promotion_valid?(promo_code) }.reject { |t| t == false }.empty?
  end

  def total_cost
    scan_items.inject(0) { |sum, scan_item| sum + loaded_data_as_hash[scan_item].to_h[:price].to_f }
  end

  def total_with_1_promotion
    if PROMOTIONAL_RULES[:discount_by_cost] == promotional_rules.first
      sum_all = total_discount_by_cost
    end
    if PROMOTIONAL_RULES[:discount_by_number_item] == promotional_rules.first
      sum_all = total_discount_by_number_item
    end
    sum_all.round(2)
  end

  def total_discount_by_number_item
    change_price
    total_cost
  end

  def total_discount_by_cost(cost = total_cost)
    if cost >= PROMOTIONAL_COST_TO_DISCOUNT
      discount_percent = 1.0 - PROMOTIONAL_PERCENT_DISCOUNT / 100.0
      return (cost * discount_percent)
    end
    cost
  end

  def change_price
    discount_items = []
    items_size = number_of_items
    DISCOUNT_ITEMS.map do |d_item|
      found_discount_item = loaded_data.find do |item|
        item[:code] == d_item[:code] && \
          items_size[item[:code]] >= d_item[:amount_to_discount]
      end
      unless found_discount_item.nil?
        discount_items << found_discount_item.merge(d_item)
      end
    end
    loaded_data_as_hash.merge!(discount_items.index_by { |item| item[:code] })
  end

  def number_of_items
    result = Hash.new(0)
    scan_items.each_with_index { |value, _index| result[value] += 1 }
    result
  end
end
