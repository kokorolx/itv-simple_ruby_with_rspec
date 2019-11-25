# frozen_string_literal: true

require_relative '../checkout'
require_relative '../constants.rb'

describe Checkout do
  it 'scan item without database' do
    checkout = Checkout.new
    checkout.scan('00001')
    checkout.scan('00002')
    expect(checkout.total).to eq 0
  end

  it 'scan promotion without database' do
    checkout = Checkout.new('dont_have_this_promotion')
    checkout.scan('001')
    checkout.scan('002')
    expect(checkout.total).to eq 0
  end

  it 'scan some promotions without database' do
    checkout = Checkout.new('dont_have_this_promotion, discount_by_number_item')
    checkout.scan('001')
    checkout.scan('002')
    expect(checkout.total).to eq 54.25
  end

  it 'scan some promotions without database and more space' do
    checkout = Checkout.new('dont_have_this_promotion, discount_by_number_item    ')
    checkout.scan('001')
    checkout.scan('002')
    expect(checkout.total).to eq 54.25
  end

  it 'scan duplicate promotional_rules' do
    checkout = Checkout.new('discount_by_number_item, discount_by_number_item    ')
    checkout.scan('001')
    checkout.scan('002')
    expect(checkout.total).to eq 54.25
  end

  describe 'Total without promotion' do
    before(:each) do
      @checkout = Checkout.new
    end
    it 'dont scan item' do
      expect(@checkout.total).to eq 0
    end

    it 'scan 1 item' do
      @checkout.scan('001')
      expect(@checkout.total).to eq 9.25
    end

    it 'scan 1 item 2 times' do
      @checkout.scan('001')
      @checkout.scan('001')
      expect(@checkout.total).to eq 9.25 * 2
    end

    it 'scan some items without database ' do
      @checkout.scan('002')
      @checkout.scan('0022')
      @checkout.scan('003')
      expect(@checkout.total).to eq 64.95
    end

    it 'scan some items with order' do
      @checkout.scan('001')
      @checkout.scan('001')
      @checkout.scan('002')
      @checkout.scan('003')
      expect(@checkout.total).to eq 83.45
    end
    it 'scan some items without order' do
      @checkout.scan('001')
      @checkout.scan('002')
      @checkout.scan('001')
      @checkout.scan('003')
      expect(@checkout.total).to eq 83.45
    end
  end

  describe 'Total with promotions' do
    context 'with discount_by_number_item promotion' do
      before(:each) do
        @checkout = Checkout.new('discount_by_number_item')
      end
      it 'number of items < amount_to_discount' do
        @checkout.scan('001')
        expect(@checkout.total).to eq 9.25
      end

      it 'number of items == amount_to_discount' do
        @checkout.scan('001')
        @checkout.scan('001')
        expect(@checkout.total).to eq 8.5 * 2
      end

      it 'number of items > amount_to_discount' do
        @checkout.scan('001')
        @checkout.scan('001')
        @checkout.scan('001')
        expect(@checkout.total).to eq 8.5 * 3
      end

      it 'item without discount_by_number' do
        @checkout.scan('002')
        @checkout.scan('002')
        expect(@checkout.total).to eq 45.0 * 2
      end

      it 'number of items > amount_to_discount and some other items' do
        @checkout.scan('001')
        @checkout.scan('003')
        @checkout.scan('001')
        expect(@checkout.total).to eq 36.95
      end

      it 'some items without order' do
        @checkout.scan('001')
        @checkout.scan('002')
        @checkout.scan('001')
        @checkout.scan('003')
        expect(@checkout.total).to eq 81.95
      end

      it 'discount 2 items --- number of items < amount_to_discount and some other items' do
        @checkout.scan('003')
        @checkout.scan('001')
        @checkout.scan('004')
        expect(@checkout.total).to eq 49.2
      end

      it 'discount 2 items --- number of items == amount_to_discount and some other items' do
        @checkout.scan('001')
        @checkout.scan('001')

        @checkout.scan('003')

        @checkout.scan('004')
        @checkout.scan('004')
        expect(@checkout.total).to eq 36.95
      end

      it 'discount 2 items --- number of items <= amount_to_discount and some other items' do
        @checkout.scan('004')
        @checkout.scan('003')

        @checkout.scan('001')
        @checkout.scan('001')
        expect(@checkout.total).to eq 56.95
      end

      it 'discount 2 items --- number of items > amount_to_discount and some other items' do
        @checkout.scan('003')

        @checkout.scan('001')
        @checkout.scan('001')
        @checkout.scan('001')

        @checkout.scan('004')
        @checkout.scan('004')
        @checkout.scan('004')
        expect(@checkout.total).to eq 45.45
      end

      it 'discount 3 items --- number of items < amount_to_discount and some other items' do
        @checkout.scan('003')

        @checkout.scan('001')
        @checkout.scan('001')
        @checkout.scan('001')

        @checkout.scan('004')
        @checkout.scan('004')
        @checkout.scan('004')
        @checkout.scan('005')
        expect(@checkout.total).to eq 55.45
      end

      it 'discount 3 items --- number of items == amount_to_discount and some other items' do
        @checkout.scan('003')

        @checkout.scan('001')
        @checkout.scan('001')
        @checkout.scan('001')

        @checkout.scan('004')
        @checkout.scan('004')
        @checkout.scan('004')
        @checkout.scan('005')
        @checkout.scan('005')
        @checkout.scan('005')
        expect(@checkout.total).to eq 48.45
      end

      it 'discount 3 items --- number of items > amount_to_discount and some other items' do
        @checkout.scan('003')

        @checkout.scan('001')
        @checkout.scan('001')
        @checkout.scan('001')
        @checkout.scan('004')
        @checkout.scan('004')
        @checkout.scan('004')
        @checkout.scan('005')
        @checkout.scan('005')
        @checkout.scan('005')
        @checkout.scan('005')
        expect(@checkout.total).to eq 49.45
      end
    end

    context 'with discount_by_cost promotion' do
      before(:each) do
        @checkout = Checkout.new('discount_by_cost')
      end
      it 'discount_by_cost = 0' do
        @checkout.scan('000')
        expect(@checkout.total).to eq 0
      end

      it "discount_by_cost > 0 && discount_by_cost < #{Constants::PROMOTIONAL_COST_TO_DISCOUNT}" do
        @checkout.scan('001')
        @checkout.scan('003')
        expect(@checkout.total).to eq 29.2
      end

      it "discount_by_cost == #{Constants::PROMOTIONAL_COST_TO_DISCOUNT}" do
        @checkout.scan('004')
        @checkout.scan('004')
        @checkout.scan('004')
        expect(@checkout.total).to eq 54.0
      end

      it "discount_by_cost > #{Constants::PROMOTIONAL_COST_TO_DISCOUNT}" do
        @checkout.scan('001')
        @checkout.scan('002')
        @checkout.scan('001')
        @checkout.scan('003')
        expect(@checkout.total).to eq 75.11
      end
    end

    context 'with discount_by_number_item and discount_by_cost' do
      before(:each) do
        @checkout = Checkout.new('discount_by_cost, discount_by_number_item')
      end
      it "don't discount_by_number_item and don't discount_by_cost" do
        @checkout.scan('001')
        expect(@checkout.total).to eq 9.25
      end

      it "discount_by_number_item but don't discount_by_cost" do
        @checkout.scan('001')
        @checkout.scan('003')
        @checkout.scan('001')
        expect(@checkout.total).to eq 36.95
      end

      it "discount_by_cost but don't discount_by_number_item" do
        @checkout.scan('001')
        @checkout.scan('003')
        @checkout.scan('002')
        expect(@checkout.total).to eq 66.78
      end

      it 'discount_by_cost and discount_by_number_item' do
        @checkout.scan('001')
        @checkout.scan('002')
        @checkout.scan('001')
        @checkout.scan('003')
        expect(@checkout.total).to eq 73.76
      end

      it 'discount 2 items -- discount_by_cost and discount_by_number_item' do
        @checkout.scan('001')
        @checkout.scan('002')
        @checkout.scan('001')
        @checkout.scan('003')
        @checkout.scan('004')
        @checkout.scan('004')
        expect(@checkout.total).to eq 73.76
      end

      it 'discount 3 items -- discount_by_cost and discount_by_number_item' do
        @checkout.scan('001')
        @checkout.scan('002')
        @checkout.scan('001')
        @checkout.scan('003')
        @checkout.scan('004')
        @checkout.scan('004')
        @checkout.scan('005')
        @checkout.scan('005')
        @checkout.scan('005')
        expect(@checkout.total).to eq 76.46
      end
      it 'discount 3 items -- duplicate rules discount_by_cost and discount_by_number_item' do
        checkout = Checkout.new('discount_by_cost   , discount_by_cost, discount_by_number_item, dont_have_this')
        checkout.scan('001')
        checkout.scan('002')
        checkout.scan('001')
        checkout.scan('003')
        checkout.scan('004')
        checkout.scan('004')
        checkout.scan('005')
        checkout.scan('005')
        checkout.scan('005')
        expect(checkout.total).to eq 76.46
      end
    end
  end
end
