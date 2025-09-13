FactoryBot.define do
    factory :cart do
        total_price { 0.0 }
        
        trait :with_items do
            after(:create) do |cart|
                create_list(:cart_item, 1, cart: cart)
                cart.update(total_price: cart.cart_items.sum { |item| item.product.price * item.quantity })
            end
        end
    end
end