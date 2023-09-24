require 'rails'

module Crudify
  class Engine < ::Rails::Engine
    isolate_namespace Crudify

    # Load engine dependencies
    #{}require_relative "../tasks"

    require "active_support/dependencies"

    # # Mount engine routes
    # initializer "crudify.routes" do
    #   Crudify::Engine.routes.draw do
    #     get "crud", to: "crud#index"
    #   end
    # end
  
    initializer 'crudify.asset_pipeline' do |app|
      app.config.assets.paths << root.join('app', 'assets', 'images').to_s
    end

    initializer "crudify.assets.precompile" do |app|
      app.config.assets.precompile += %w( crudify/download-icon-1.png )
    end
    
  end
end