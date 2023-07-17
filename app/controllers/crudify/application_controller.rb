module Crudify
  #class ApplicationController < ActionController::Base
  class ApplicationController < ::MmsApiController
    protect_from_forgery with: :exception
  end
end