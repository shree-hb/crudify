module Crudify
  #class ApplicationController < ActionController::Base
  class ApplicationController < ::MmsApiController
    protect_from_forgery with: :exception
    skip_before_action :authenticate_user! , :if => proc {!Rails.application.config.content_engine[:is_auth_enabled]}


  end
end