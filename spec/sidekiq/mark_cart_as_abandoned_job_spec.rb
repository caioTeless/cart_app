require 'rails_helper'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
    let!(:cart1) { Cart.create!(abandoned: false, total_price: 10.0) }
    let!(:cart2) { Cart.create!(abandoned: false, total_price: 20.0) }
    let!(:cart3) { Cart.create!(abandoned: true, total_price: 30.0) }

    describe '#perform' do
        it 'marks inactive carts as abandoned' do
            cart1.update_column(:updated_at, 4.hours.ago)
            cart2.update_column(:updated_at, 2.hours.ago)

            expect { MarkCartAsAbandonedJob.new.perform }.to change { cart1.reload.abandoned? }.from(false).to(true)
            expect(cart2.reload.abandoned?).to be_falsey
        end
    end
end
