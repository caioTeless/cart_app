class MarkCartAsAbandonedJob
  include Sidekiq::Job
  sidekiq_options queue: 'default'

  def perform(*args)
    Cart.to_abandoned.find_each do |cart|
      cart.mark_as_abandoned
    end

  rescue StandardError => error
    Rails.logger.error "Error marking carts as abandoned: #{error.message}"
  end
end
