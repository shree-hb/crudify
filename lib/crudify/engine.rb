module Crudify
  class Engine < ::Rails::Engine
    isolate_namespace Crudify

    # Load engine dependencies
    require "crudify/crud_controller"

    # Mount engine routes
    initializer "crudify.routes" do
      Crudify::Engine.routes.draw do
        get "crud", to: "crud#index"
      end
    end
  end
end