require 'rails_helper'

RSpec.describe Cart, type: :model do
  context 'when validating' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include("must be greater than or equal to 0")
    end
  end

  describe 'associations' do
    it { should have_many(:cart_items).dependent(:destroy) }
    it { should have_many(:products).through(:cart_items) }
  end

  describe 'mark_as_abandoned' do
    let(:cart) { create(:cart, updated_at: 3.hours.ago) }

    it 'marks the shopping cart as abandoned if inactive for a certain time' do
      expect { cart.mark_as_abandoned }.to change { cart.reload.abandoned? }.from(false).to(true)
    end
  end

  describe 'remove_if_abandoned' do
    let(:cart) { create(:cart, abandoned: false) }

    it 'removes the shopping cart if abandoned for a certain time' do
      cart.mark_as_abandoned
      cart.update_column(:updated_at, 8.days.ago)

      expect { Cart.to_remove.destroy_all }.to change { Cart.count }.by(-1)
    end
  end

  describe 'scopes' do
    let(:active_cart) { create(:cart, abandoned: false, updated_at: 1.hour.ago) }
    let(:inactive_cart) { create(:cart, abandoned: false, updated_at: 4.hours.ago) }
    let(:abandoned_cart) { create(:cart, abandoned: true, updated_at: 8.days.ago) }
    let(:recently_abandoned_cart) { create(:cart, abandoned: true, updated_at: 2.days.ago) }

    it 'returns carts that are inactive for more than 3 hours' do
      expect(Cart.to_abandoned).to include(inactive_cart)
      expect(Cart.to_abandoned).not_to include(active_cart)
    end

    it 'returns carts that are abandoned for more than 7 days' do
      expect(Cart.to_remove).to include(abandoned_cart)
      expect(Cart.to_remove).not_to include(recently_abandoned_cart)
    end
  end
end
