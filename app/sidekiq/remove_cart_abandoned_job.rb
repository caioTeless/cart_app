class RemoveCartAbandonedJob
  include Sidekiq::Job
  sidekiq_options queue: 'default'

  def perform(*args)
    Cart.to_remove.delete_all

  rescue StandardError => error
    Rails.logger.error "Error removing abandoned carts: #{error.message}"
  end
end