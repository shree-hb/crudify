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
              is_polymorphic = obj.class.polymorphic_content&.delete_if{|n| n.eql?(:polymorphic_content) }
              if is_polymorphic.blank?
                poly_model =  obj.class.reflections.select { |name, reflection| reflection.options[:polymorphic] == true }
                model = poly_model.keys.first
              else
                model = ""
              end
              
              if !is_polymorphic.blank? && col_name.match(model)
                collection1 = nil
                is_polymorphic.each do |poly_model|
                  col_arr = poly_model.to_s.camelize.constantize.all.collect{|s| [ "#{s.class.name} - #{s.send(s.class.relational_display_col)}", s.id ] } rescue []
                  collection1.nil? ? collection1 = col_arr : collection1.concat(col_arr)
                end         
              else
                relational_model = col_name.to_s.split(/_id$/)[0].capitalize
                collection1 = relational_model.camelize.constantize.all.collect{|s| [s.send(s.class.relational_display_col), s.id ] } rescue []
              end
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

    def polymorphic_select(obj, col_name)
      binding.pry
      models = obj.class.polymorphic_content.delete_if{|n| n.eql?(:polymorphic_content) }
      collection =  models.map { |s| s.to_s.classify }
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



