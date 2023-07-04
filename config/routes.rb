Crudify::Engine.routes.draw do
  get "crud", to: "crud#index"

  resources :cruds
  root "cruds#index"
  
end