Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://redis:6379/0' }

  require 'sidekiq-scheduler'

  config.on(:startup) do
    schedule_file = Rails.root.join('config/sidekiq.yml')

    if File.exist?(schedule_file)
      schedule = YAML.load_file(schedule_file)
      scheduler_jobs = schedule[:scheduler] || {}
      Sidekiq.schedule = scheduler_jobs
      Sidekiq::Scheduler.reload_schedule!
    end
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'] || 'redis://redis:6379/0' }
end
