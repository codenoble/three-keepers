source 'https://rubygems.org'

gem 'rails', '4.1.7.1'

gem 'blazing'
gem 'biola_deploy'
gem 'biola_frontend_toolkit', '>= 0.3.1'
gem 'chronic_ping'
gem 'coffee-rails', '~> 4.0.0'
# FIXME: point at the real gem once it exists
gem 'google_syncinator_api_client', github: 'codenoble/google-syncinator-api-client'
gem 'jquery-rails', '~> 3.1.3'
gem 'jquery-ui-rails'
gem 'kaminari-bootstrap'
gem 'madgab'
gem 'newrelic_rpm'
gem 'pinglish'
gem 'puma'
gem 'rack-cas'
gem 'rack-ssl'
gem 'rails_config'
gem 'reform'
gem 'sass-rails', '~> 4.0.4'
gem 'sidekiq'
gem 'sidekiq-cron'
gem 'sinatra', require: false
gem 'therubyracer', platforms: :ruby
gem 'trogdir_models'
gem 'turnout'
gem 'uglifier', '>= 1.3.0'
gem 'virtus'

group :development, :test do
  gem 'pry'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'letter_opener'
  gem 'spring'
end

group :test do
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'launchy'
  gem 'rspec-rails'
end

group :staging, :production do
  gem 'biola_logs'
end

group :production do
  gem 'sentry-raven'
end
