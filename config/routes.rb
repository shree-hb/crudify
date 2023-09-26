Crudify::Engine.routes.draw do
  
  resources :cruds
  get 'crudify/export_delta_json' =>'cruds#export_delta_json'
  root "cruds#index"
  get 'delete_content', to: 'cruds#delete_content'
end
