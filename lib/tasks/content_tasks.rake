namespace :crudify do
  
  desc 'Generate initializer file for content engine in HOL app'
  task generate_initializer: :environment do
    
    initializer_content = <<~RUBY
      require 'crudify/content_crud'

      ActiveSupport.on_load(:active_record) do
        include Crudify::ContentCrud
      end
      
      Rails.application.config.content_engine = {
        content_models: [ 'Department' ],
        application_name: "Secure Start ",
        main_theme_color: "#8A6E93",
        secondary_theme_color: "#8A6E931",
        is_auth_enabled: false
      }
    RUBY

    File.open('config/initializers/content_engine.rb', 'w') do |file|
      file.write(initializer_content)
    end
    puts 'Initializer file generated successfully!'
  end

  desc "Add code to mode to specify attributes required for CRUD interface"
  task :crudify_model, [:arg1, :arg2, :arg3] do |t,args|
    #{}debugger
    unless args[:arg1].nil? || args[:arg2].nil? || args[:arg3].nil?
      model_attr =  Rack::Utils.parse_nested_query(args[:arg1])      
      model = args[:arg2]
      display_val = args[:arg3]
      inject_code(model, model_attr, display_val )
    else      
      initial_content_models.each do |ct|
        model_attr =Rack::Utils.parse_nested_query(ct[0])
        model = ct[1]
        display_val = ct[2]
        inject_code(model, model_attr, display_val )
      end
    end
  end 


  def initial_content_models 
    ar = [ ['name=txt&display_name=txt&department_type=txt', 'Department', 'name'] ,
           ['title=txt&action=txt&resource_category_id=txt&description=txt&display_value=txt','Resource', 'title'],
           ['name=txt&department_id=txt','ResourceCategory', 'name'],
           ['message=txt&template_type=enum','SmsTemplate', 'template_type'],
           ['template_type=enum&subject=txt&body=txt','EmailTemplate','template_type'],
           ['type=txt&subject=txt&body=txt&notification_identifier=txt&link_entity_type=txt&link_entity_identifier=txt','NotificationTemplate', 'subject'],
           ['title=txt&name=txt&type=enum&action_to_perform=enum&task_type=enum&task_identifier=txt&link_data=txt'  ,'Task', 'title'],
           ['message=txt&task_id=txt&task_reminder_identifier=txt','TaskReminder', 'message'],
           ['answer_type=enum&kind=enum&text=txt&question_id=txt&link_data=txt','Answer','answer_type'],
           ['question_type=enum&kind=enum&text=txt&question_identifier=txt&question_category_id=txt&question_section_id=txt&order=txt','Question','text'],
           ['name=txt&order=txt&questions_count=txt','QuestionCategory','name'],
           ['name=txt&order=txt&question_category_id=txt','QuestionSection','name'],
           ['name=txt&department_id=txt&internal_name=txt','Procedure','name'],
           ['procedure_id=txt&modifier_type=enum&value=txt&modifier_identifier=txt&is_own_product=txt','ProcedureModifier','display_name'] 
         ]
  end
  
  def inject_code(model, model_attr, display_val )
    model_file_path = "app/models/#{model.underscore}.rb"
    keyword = "has_"
    keyword1 = 'belongs_'
    params = []
    
    model_attr.each do |f,v|
      params << "#{f}: '#{v},1'"
    end

    code_block = <<-HEREDOC   
# Content CRUDIFY Engine 
  # Syntax  
  # crud_col_hash   filed_name: "<data-type>,<is_editable>"
  # <data-type> can be : 'txt' / 'enum'
  # <is_editable> can be : 1 for true i.e. field is Editable
  #                        0 for false i.e. field is NOT Editable          
  crud_col_hash #{params.join(', ')}

  relational_display_col :#{display_val}


    HEREDOC
   
    contents = File.read(model_file_path)
    modified_lines = []
    found_last_line = false
    
    contents.lines.reverse_each do |line| 
      if !found_last_line && line.strip.start_with?(keyword)
        existing_code = "#{line}"

        if existing_code.present?
          existing_code += "\n  #{code_block}"
        end     
        modified_lines.unshift("#{existing_code}")

        found_last_line = true
      elsif !found_last_line && line.strip.start_with?(keyword1) 
        existing_code = "#{line}"

        if existing_code.present?
          existing_code += "\n  #{code_block}"
        end     
        modified_lines.unshift("#{existing_code}")

        found_last_line = true
      else
        modified_lines.unshift(line)
      end
    end     
 
    File.write(model_file_path, modified_lines.join, encoding: "UTF-8")
    puts "Check model #{model}, Crudify column code added"
  end
end