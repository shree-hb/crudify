module Crudify
  class CrudsController < ApplicationController
    layout 'crudify_base'
    skip_before_action :verify_authenticity_token, only: [:delete_content]


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
      ArchiveLog.track_create_log(form_obj)
      #{}form_obj.save
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
      ArchiveLog.track_log(content_obj, 'update')
      #{}content_obj.save
      redirect_to cruds_path({model: @model})
    end
   
    def export_delta_json 
      changes = ArchiveLog.non_archived      
      # Serialize and save
      if changes.present?
        revision = changes.last.id
        # Format the time to get YYYYMMDD_HHMMSS_SSS
        formatted_time = Time.now.strftime('%d%m%Y_%H%M%S_%L')
        file_name = "CrudifyDelta_#{formatted_time}_revision#{revision}"
        File.open("#{Rails.root}/db/content/#{file_name}.json", "w") do |f|
          f.write(changes.to_json)
        end
      end
      flash[:notice] = "The Delta file: <span class='highlighted-filename'>#{file_name}.json</span> 
                        was imported successfully, find the file at this path: <span class='highlighted-filename'>db/content/</span>."
      redirect_to cruds_path({model: @model})
    end

    def delete_content
      record_ids = params["id"].split(',')
      @model = params[:model]
      ArchiveLog.track_delete_log(record_ids)
      #{}redirect_to cruds_path({model: @model})
      flash[:notice] = "Deleted successfully."
      respond_to do |format|
        format.js { render 'delete_content' }
      end
    end

    private

    def init
      @model = params[:model]
      parent_class = self.class.superclass
      @model_class = parent_class.const_get(@model) rescue Department
    end
  end
end