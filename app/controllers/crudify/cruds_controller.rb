class Crudify::CrudsController < ::ApplicationController
  layout 'crudify/content'

  before_action :init

  def index 
    @contents = @model_class.all rescue ::Department.all
  end

  def new
    @content = @model_class.new    
  end
  
  def create
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
    @content =  @model_class.find_by_id(params[:id])        
  end

  def update
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


