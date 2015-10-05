Sidekiq.configure_server do |config|
  config.redis = { url: Settings.redis.url, namespace: Settings.redis.name }
end

Sidekiq.configure_client do |config|
  config.redis = { url: Settings.redis.url, namespace: Settings.redis.name }
end

schedule_file = "config/schedule.yml"

if File.exists?(schedule_file)
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end
