Crudify::Engine.routes.draw do
  
  resources :cruds

  root "cruds#index"

end