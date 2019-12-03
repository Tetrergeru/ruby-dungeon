Rails.application.routes.draw do
  get '/auth/login', to: 'sessions#index'
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/logout', to: 'sessions#destroy'
  get '/game/:action_id', to: 'game#game'
  get '/game', to: 'game#game'
  root 'home#index'
end
