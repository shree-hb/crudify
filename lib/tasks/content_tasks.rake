namespace :crudify do
  
  desc 'Generate initializer file for content engine in HOL app'
  task generate_initializer: :environment do
    
    initializer_content = <<~RUBY
      require 'content/content_crud'

      ActiveSupport.on_load(:active_record) do
        include Content::ContentCrud
      end
      
      Rails.application.config.content_engine = {
        content_models: [ 'Department' ],
        application_name: "Secure Start ",
        main_theme_color: "#8A6E93",
        secondary_theme_color: "#8A6E931"
      }
    RUBY

    File.open('config/initializers/content_engine.rb', 'w') do |file|
      file.write(initializer_content)
    end
    puts 'Initializer file generated successfully!'
  end

  desc "Add code to mode to specify attributes required for CRUD interface"
  task :crudify_model, [:arg1, :arg2] do |t,args|
    model_attr =  Rack::Utils.parse_nested_query(args[:arg1])
    model = args[:arg2]
    model_file_path = "app/models/#{model.underscore}.rb"
    keyword = "has_"
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
      else
        modified_lines.unshift(line)
      end
    end     
 
    File.write(model_file_path, modified_lines.join, encoding: "UTF-8")
    puts "Check your model #{model}, content column code added"
  end

end