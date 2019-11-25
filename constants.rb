# frozen_string_literal: true

module Constants
  SAMPLE_DATA = [
    { code: '000', name: 'Custom item', price: 0 },
    { code: '001', name: 'Lavender heart', price: 9.25 },
    { code: '002', name: 'Personalised cufflinks', price: 45.00 },
    { code: '003', name: 'Kids T-shirt', price: 19.95 },
    { code: '004', name: 'Custom item 2', price: 20 },
    { code: '005', name: 'Custom item 3', price: 10 }
  ].freeze

  DISCOUNT_ITEMS = [
    { code: '001', name: 'Lavender heart', price: 8.50, amount_to_discount: 2 },
    { code: '004', name: 'Custom item 2', price: 0, amount_to_discount: 2 },
    { code: '005', name: 'Custom item 3', price: 1, amount_to_discount: 3 }
  ].freeze
  PROMOTIONAL_RULES = { discount_by_cost: 'discount_by_cost', discount_by_number_item: 'discount_by_number_item' }.freeze
  PROMOTIONAL_COST_TO_DISCOUNT = 60
  PROMOTIONAL_PERCENT_DISCOUNT = 10
end
