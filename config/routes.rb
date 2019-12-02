Rails.application.routes.draw do
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/logout', to: 'sessions#destroy'
  get '/game/:action_id', to: 'game#game'
  get '/game', to: 'game#game'
  get 'levels/index'
  put 'levels/create', action: :create, controller: 'levels'
  root 'application#index'
end
