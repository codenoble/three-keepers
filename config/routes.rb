require 'sidekiq/web'
require 'sidekiq/cron/web'
Rails.application.routes.draw do

  mount Sidekiq::Web, at: '/sidekiq'

  resources :people, only: [:index, :show]
  resources :syncinators, only: [:index, :show]
  resources :changesets, only: :show do
    resources :change_syncs, only: :update
  end

  # this is just a convenience to create a named route to rack-cas' logout
  get '/logout' => -> env { [404, { 'Content-Type' => 'text/html' }, ['Rack::CAS should have caught this']] }, as: :logout

  root to: 'people#index'
end
