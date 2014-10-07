Rails.application.routes.draw do
  resources :people, only: [:index, :show]

  root to: 'people#index'
end
