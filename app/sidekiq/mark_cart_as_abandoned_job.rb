class MarkCartAsAbandonedJob
  include Sidekiq::Job
  sidekiq_options queue: 'default'

  def perform(*args)
    Cart.to_abandoned.update_all(abandoned: true)

  rescue StandardError => error
    Rails.logger.error "Error marking carts as abandoned: #{error.message}"
  end
end
