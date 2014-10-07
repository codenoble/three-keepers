Rails.application.routes.draw do
  resources :people, only: [:index, :show]

  # this is just a convenience to create a named route to rack-cas' logout
  get '/logout' => -> env { [404, { 'Content-Type' => 'text/html' }, ['Rack::CAS should have caught this']] }, as: :logout

  root to: 'people#index'
end
