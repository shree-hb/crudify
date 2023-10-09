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
      skip_relation = obj.class&.skip_relation&.respond_to?(:include?) && obj.class&.skip_relation.include?(col_name)
      tag = if col_name.match(/_id$/) && !skip_relation
             # is_polymorphic = obj.class.polymorphic_content&.delete_if{|n| n.eql?(:polymorphic_content) }
              content = obj.class.respond_to?(:polymorphic_content) ? obj.class.polymorphic_content : nil
              is_polymorphic = content.is_a?(Array) ? content.delete_if { |n| n.eql?(:polymorphic_content) } : nil
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
              collection1.unshift(["--- Select Empty ---", ""])
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

    def get_action_tag(obj)
      non_archived = ArchiveLog.where(class_id: obj.id, class_type: obj.class.name, action: 'delete', is_exported: false )
      if non_archived.present?
        return  "<span style='color:red;font-weight:bold;'> DELETED </span>"
      else 
        return nil
      end
    end

    def get_child_action_tag(obj, child_obj_class)
      non_archived = ArchiveLog.where(class_id: obj.id, class_type: obj.class.name, action: 'delete', is_exported: false )
      if non_archived.present?
        return  "<span style='color:red;font-weight:bold;'> DELETED #{child_obj_class} </span></br></br>"
      else 
        return nil
      end
    end

    def delete_count(obj)
      ArchiveLog.unarchived_deleted(obj.name).count
    end

  end
end