module Crudify
  #class ApplicationController < ActionController::Base
  class CrudController < ::ApplicationController
    
    def index
      p 'index' 
    end

  end
end