Rails.application.routes.draw do
  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/logout', to: 'sessions#destroy'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  # FIXME
  post 'users/new', action: :new, controller: 'users'
  # TODO: use id
  get 'users/:name', action: :show, controller: 'users'

  get 'levels/index'

  # TODO: determine the level of the user
  get 'levels/show/:id', action: :show, controller: 'levels' 
  get 'levels/show/:id/:item_id', action: :show_item, controller: 'levels' 
  put 'levels/create', action: :create, controller: 'levels'
  get '/:id', action: :index, controller: :application
  root 'levels#index'

end
