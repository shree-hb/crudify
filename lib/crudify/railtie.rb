module Crudify
  class Railtie < Rails::Railtie
    initializer 'crudify.load_app_instance_data' do |app|
      Crudify.setup do |config|
        config.app_root = app.root
      end
    end
    

    rake_tasks do
      rake_path = File.expand_path("../../lib/taks", __FILE__)
      load "#{rake_path}/your_gem_name_tasks.rake"
    end
  end
end
