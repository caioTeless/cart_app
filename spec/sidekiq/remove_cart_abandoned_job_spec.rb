require 'rails_helper'

RSpec.describe RemoveCartAbandonedJob, type: :job do
    let!(:cart1) { Cart.create!(abandoned: true, total_price: 10.0) }
    let!(:cart2) { Cart.create!(abandoned: true, total_price: 20.0) }
    let!(:cart3) { Cart.create!(abandoned: false, total_price: 30.0) }

    describe '#perform' do
        it 'removes abandoned carts' do
            cart1.update_column(:updated_at, 8.days.ago)
            cart2.update_column(:updated_at, 5.days.ago)

            expect { RemoveCartAbandonedJob.new.perform }.to change { Cart.count }.by(-1)
            expect(Cart.exists?(cart2.id)).to be_truthy
        end
    end
end