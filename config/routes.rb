Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  # FIXME
  post 'users/new', action: :new, controller: 'users'
  # TODO use id
  get 'users/:name', action: :show, controller: 'users'

  get 'levels/index'

  # TODO determine the level of the user
  get 'levels/show/:id', action: :show, controller: 'levels' 
end
