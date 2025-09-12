class CartItem < ApplicationRecord
    belongs_to :cart
    belongs_to :product

    delegate :id, :name, :price, to: :product, prefix: true
end
