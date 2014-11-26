require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"

Bundler.require(*Rails.groups)

module ThreeKeepers
  class Application < Rails::Application
    config.autoload_paths += %W(#{config.root}/app/presenters)
    config.time_zone = 'Pacific Time (US & Canada)'
    config.eager_load_paths += %W(#{config.root}/lib)
  end
end
