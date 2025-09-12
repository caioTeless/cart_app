FactoryBot.define do 
    factory :product do
        name { "Product #{::Faker::Commerce.product_name}" }
        price { ::Faker::Commerce.price(range: 10.0..100.0) }
    end
end