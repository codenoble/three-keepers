ENV["RAILS_ENV"] = 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

Dir[Rails.root.join('spec/support/*.rb')].each {|f| require f}

Mongoid.load!('spec/config/mongoid.yml')

TrogdirModels.load_factories
FactoryGirl.factories.clear
FactoryGirl.find_definitions

Capybara.asset_host = URI::HTTP.build(scheme: 'http', host: Settings.app.host).to_s

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.before(:each) do
    config.include FactoryGirl::Syntax::Methods

    Mongoid::Sessions.default.collections.select {|c| c.name !~ /system/ }.each(&:drop)
  end
end
