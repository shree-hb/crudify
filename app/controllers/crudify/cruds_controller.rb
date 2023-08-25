module Crudify
  class CrudsController < ApplicationController
    layout 'crudify_base'

    before_action :init

    def index
      if current_user.present? && Rails.application.config.content_engine[:is_auth_enabled]
          authorize current_user, :create_provider_and_location?
      end

      @contents = @model_class.all rescue ::Department.all
    end

    def new
      if current_user.present? && Rails.application.config.content_engine[:is_auth_enabled]
          authorize current_user, :create_provider_and_location?
      end

      @content = @model_class.new
    end

    def create
      if current_user.present? && Rails.application.config.content_engine[:is_auth_enabled]
          authorize current_user, :create_provider_and_location?
      end

      model = params[:model]
      form_attr = params[model.underscore]
      form_obj  = model.constantize.new()
      form_attr.each do |k|
        if form_obj.send(k[0]).class.eql?(Array)
          form_obj[k[0]] = [JSON.parse(form_attr[k[0]].gsub('[','').gsub(']', '').gsub('=>', ':'))]
        else
          form_obj[k[0]] =  k[1]
        end
      end
      form_obj.save
      redirect_to cruds_path({model: @model})
    end

    def edit
      if current_user.present? && Rails.application.config.content_engine[:is_auth_enabled]
          authorize current_user, :create_provider_and_location?
      end

      @content =  @model_class.find_by_id(params[:id])
    end

    def update
      if current_user.present? && Rails.application.config.content_engine[:is_auth_enabled]
          authorize current_user, :create_provider_and_location?
      end

      form_attr = params[@model.underscore.to_sym]
      content_obj =  @model_class.find_by_id(params[:id])
      form_attr.each do |k|
        if content_obj.send(k[0]).class.eql?(Array)
          content_obj[k[0]] = [JSON.parse(form_attr[k[0]].gsub('[','').gsub(']', '').gsub('=>', ':'))]
        else
          content_obj[k[0]] =  k[1]
        end
      end
      content_obj.save
      redirect_to cruds_path({model: @model})
    end

    private

    def init
      @model = params[:model]
      parent_class = self.class.superclass
      @model_class = parent_class.const_get(@model) rescue Department
    end
  end
end


