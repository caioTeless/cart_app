require 'rails_helper'

RSpec.describe Cart, type: :model do
  context 'when validating' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include("must be greater than or equal to 0")
    end
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
end
