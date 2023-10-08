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
      parsed_payload = parse_payload(form_attr, form_obj)
      
      ArchiveLog.track_create_log(parsed_payload)
      redirect_to cruds_path({model: @model})
    end

    def edit     
      if current_user.present? && Rails.application.config.content_engine[:is_auth_enabled]
          authorize current_user, :create_provider_and_location?
      end    
      @parent_identifier = parent_identifier_params
      @parent_model = params[:parent_model]
  
      if @parent_model
        @rel_model = params[:model]
        @content = @parent_model.constantize.where(@parent_identifier).first.send(@model)
      else 
        @content =  @model_class.find_by_id(params[:id])
      end
    end

    def update
      parent_identifier = parent_identifier_params
      if current_user.present? && Rails.application.config.content_engine[:is_auth_enabled]
          authorize current_user, :create_provider_and_location?
      end
      @parent_identifier = parent_identifier_params || nil
      @parent_model = params[:parent_model] || nil
      @rel_model = params[:child_relation] || nil
      
      form_attr = params[@model.underscore.to_sym]

      if @parent_model
        content_obj = @parent_model.constantize.where(@parent_identifier).first.send(@rel_model)
      else 
        identifiers = @model_class.content_identifier
        condition = fetch_by_identifier(identifiers, form_attr)
        content_obj = @model_class.where(condition).first
      end  
      parsed_payload = parse_payload(form_attr, content_obj)
      
      ArchiveLog.track_log(parsed_payload, 'update', @parent_identifier, @parent_model, @rel_model)
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

  #   def delete_content
  #     binding.pry
  #     # record_ids = params["id"].split(',')
  #     # @model = params[:model]
  #     # ArchiveLog.track_delete_log(record_ids)
  #     # #{}redirect_to cruds_path({model: @model})
  #     # flash[:notice] = "Deleted successfully."
  #     # respond_to do |format|
  #     #   format.js { render 'delete_content' }
  #     # end
  #      # Parsing the JSON strings into Ruby hashes
      
  # end

    def delete_content
      # Parsing the JSON strings into Ruby hashes
      parent_records = params[:parent_records].present? ? JSON.parse(valid_json_array(params[:parent_records])) : []
      child_records = params[:child_records].present? ? JSON.parse(valid_json_array(params[:child_records])) : []
      
      parent_delete_ids = []
      parent_records.each do |record_data|
        model_class = record_data["parent_model"].constantize
        conditions = record_data["parent_identifier"]
        obj = model_class.where(conditions).first
        parent_delete_ids << select_attributes(obj,:id)
      end
    
      # Handling child records
      child_delete_ids = []
      child_records.each do |record_data|
        parent_model = record_data["parent_model"].constantize
        child_model = record_data["child_model"]
        conditions = record_data["parent_identifier"]
        obj =  parent_model.where(conditions).first.send(child_model)
        child_delete_ids << select_attributes(obj,:id) 
      end

      # You can now redirect or render something
      #{}class_type = parent_delete_ids.present? ? parent_delete_ids.first["class_name"] : child_delete_ids&.first["class_name"]
      ArchiveLog.track_delete_log( [ parent_delete_ids + child_delete_ids ])
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

    def valid_json_array(json_str)
      "[#{json_str}]"
    end

    def select_attributes(obj,*keys)
      obj.slice(*keys.map(&:to_s)).merge("class_name" => obj.class.name)
    end

    def parent_identifier_params
      if params[:parent_identifier]
        params.require(:parent_identifier).permit(:notification_identifier).to_h
      else
        {}
      end
    end

    def parse_payload(form_attr, content_obj)
      form_attr.each do |k|        
        if content_obj.send(k[0]).class.eql?(Array)
          val = form_attr[k[0]].gsub('[','').gsub(']', '').gsub('=>', ':')          
          content_obj[k[0]] = val.present? ? [JSON.parse(val)] : [val]
        elsif content_obj.send(k[0]).class.eql?(Hash)                
          json_str = form_attr[k[0]].gsub(/:(\w+)=>/, '"\1": ').gsub("=>", ": ")
          content_obj[k[0]] = JSON.parse(json_str, symbolize_names: true) rescue {}
        else
        content_obj[k[0]] =  k[1]
        end
      end
      content_obj
    end 

    def fetch_by_identifier(identifiers, params)
      cond = {}
      identifiers.each do |idt|
        cond[idt.to_sym] = params["#{idt.to_s}"]
      end
      cond
    end

  end
end