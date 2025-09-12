class Cart < ApplicationRecord
  validates_numericality_of :total_price, greater_than_or_equal_to: 0
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado
  scope :to_abandoned, -> { where(abandoned: false).where('updated_at <= ?', 3.hours.ago) }
  scope :to_remove, -> { where(abandoned: true).where('updated_at <= ?', 7.days.ago) }
end
