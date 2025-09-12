FactoryBot.define do
    factory :cart do
        total_price { 0.0 }
        
        after(:create) do |cart|
            create_list(:cart_item, 1, cart: cart) if cart.cart_items.empty?
            cart.update(total_price: cart.cart_items.sum { |item| item.product.price * item.quantity })
        end
    end
end