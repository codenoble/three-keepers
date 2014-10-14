require 'rack-cas/session_store/rails/mongoid'
ThreeKeepers::Application.config.session_store :rack_cas_mongoid_store, key: '_three_keepers_session'
