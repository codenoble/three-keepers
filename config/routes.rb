require 'sidekiq/web'
require 'sidekiq/cron/web'
Rails.application.routes.draw do
  mount Sidekiq::Web, at: '/sidekiq'

  resources :people, only: [:index, :show] do
    get :search, on: :collection
  end
  resources :emails, only: :index
  resources :person_emails, except: [:index, :destroy] do
    get :search, on: :collection
    resources :deprovision_schedules, only: [:new, :create, :update, :destroy]
    resources :exclusions, only: [:new, :create, :destroy]
  end
  resources :department_emails, except: :index do
    resources :deprovision_schedules, only: [:new, :create, :update, :destroy]
    resources :exclusions, only: [:new, :create, :destroy]
  end
  resources :alias_emails, only: [:show, :new, :create]

  resources :syncinators, only: [:index, :show]
  resources :changesets, only: :show do
    resources :change_syncs, only: :update
  end

  # this is just a convenience to create a named route to rack-cas' logout
  get '/logout' => -> env { [404, { 'Content-Type' => 'text/html' }, ['Rack::CAS should have caught this']] }, as: :logout

  root to: 'people#index'
end
