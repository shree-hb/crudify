module Crudify 
  module CrudsHelper

    def content_tag_helper(col_name, obj, options = {}, disabled=false)
      form_obj = obj.class.to_s.underscore
      value =  obj.send(col_name)
      
      if options[:attr].present?  
        opt = options[:attr].split(',') 
        field_type = opt[0] rescue 'txt'
        disabled = (opt[1].eql?("1") ? false : true) rescue false
      else
        field_type = 'txt'
        disabled = false
      end 
      data_type = options[:datatype]
    
      tag = if col_name.match(/_id$/) 
              relational_model = col_name.to_s.split(/_id$/)[0].capitalize 
              collection1 = relational_model.camelize.constantize.all.collect{|s| [s.send(s.class.relational_display_col), s.id ] } rescue []
              select_tg(col_name, form_obj, value, collection1, disabled=false)
            elsif field_type.eql?('enum')
              collection =  obj.class.send("#{col_name}s").keys
              select_tg(col_name, form_obj, value, collection, disabled=false)
            elsif data_type.eql?(:boolean) 
              select_tg(col_name, form_obj, value, [true, false], disabled=false)
            elsif data_type.eql?(:text) 
              txt_box_area(col_name, form_obj, value, disabled=false)  
            else
              txt_box(col_name, form_obj, value, disabled)
            end
      tag
    end

    def txt_box(col_name, form_obj, value, disabled=false)
      text_field_tag("#{form_obj}[#{col_name}]", value, disabled: disabled, class: "input-field" )
    end
    
    def txt_box_area(col_name, form_obj, value, disabled=false)
      text_area_tag("#{form_obj}[#{col_name}]", value, disabled: disabled, class: "input-field", size: "30x15"  )
    end

    def select_tg(col_name, form_obj, value, collection, disabled=false) 
      select_tag("#{form_obj}[#{col_name}]", options_for_select(collection, value), class: "select-field")
    end

  end
end



