class CartItem < ApplicationRecord
    belongs_to :cart
    belongs_to :product

    delegate :id, :name, :price, to: :product, prefix: true

    validates_numericality_of :quantity, only_integer: true, greater_than: 0
end
