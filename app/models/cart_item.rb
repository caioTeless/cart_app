class CartItem < ApplicationRecord
    belongs_to :cart
    belongs_to :product

    validates :cart, presence: true
    validates :product, presence: true

    validates_numericality_of :quantity, only_integer: true, greater_than: 0

    delegate :id, :name, :price, to: :product, prefix: true
end
