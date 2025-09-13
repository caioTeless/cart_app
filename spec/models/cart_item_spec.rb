require 'rails_helper'

RSpec.describe CartItem, type: :model do

  describe 'associations' do
    it { should belong_to(:cart) }
    it { should belong_to(:product) }
  end

  describe 'validations' do
    it { should validate_numericality_of(:quantity).only_integer.is_greater_than(0) }
    it { should validate_presence_of(:product) }
    it { should validate_presence_of(:cart) }
  end

  context 'when create a cart' do 
    it 'creates a cart item associated with the cart' do
      cart = create(:cart)
      cart_item = create(:cart_item, cart: cart)

      expect(cart.cart_items).to include(cart_item)
    end
  end
end
