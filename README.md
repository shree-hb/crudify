# Crudify

The Crudify gem provides a CRUD interface for an existing model in Rails app. 
The model attribute which is needed for CRUD can be configured at the model level.

## Installation

Install the gem and add to the application's Gemfile below line:

    $ gem 'crudify'

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install crudify

## Usage

Once gem is installed follow below steps

In Routes.rb , Add below line

    $ mount Crudify::Engine => "crudify"

To Generate Initializer, run below rake. This will generate content_engine.rb in the root app's initializer folder.
  
    $ rake crudify:generate_initializer

To Generate CRUD for common content models like Resources, Tasks, Email Template etc , use below rake 
    $ rake crudify:crudify_model

To configure model for which CRUD needs to be enabled , run below task (change it with target model name, attribute)

   # Syntax
    $ rake "crudify:crudify_model[<attr_name=txt>&<attr_name=enum>, <Model_Name>, <Display_Attr>]" for adding to specific model
   # Department
    $ rake "crudify:crudify_model[name=txt&display_name=txt&department_type=txt&country=txt,Department, name]"
   # Resource
    $ rake "crudify:crudify_model[title=txt&action=txt&resource_category_id=txt&description=txt&display_value=txt,Resource, title]"
   # Resource Category
    $ rake "crudify:crudify_model[name=txt&department_id=txt,ResourceCategory, name]"
   # Sms Template
    $ rake "crudify:crudify_model[message=txt&template_type=enum,SmsTemplate, template_type]"
   # Email Template
    $ rake "crudify:crudify_model[template_type=enum&subject=txt&body=txt,EmailTemplate, template_type]"
   # Notification Template
    $ rake "crudify:crudify_model[type=txt&subject=txt&body=txt&notification_identifier=txt&link_entity_type=txt&link_entity_identifier=txt,NotificationTemplate, subject]"
   # Task
    $ rake "crudify:crudify_model[title=txt&name=txt&type=enum&action_to_perform=enum&task_type=enum&task_identifier=txt&link_data=txt  ,Task, title]"
   # Task Reminder
    $ rake "crudify:crudify_model[message=txt&task_id=txt&task_reminder_identifier=txt,TaskReminder, message]"
   # Answer
    $ rake "crudify:crudify_model[answer_type=enum&kind=enum&text=txt&question_id=txt&link_data=txt,Answer,answer_type]"
   # Question
    $ rake "crudify:crudify_model[question_type=enum&kind=enum&text=txt&question_identifier=txt&question_category_id=txt&question_section_id=txt&order=txt,Question,text]"
   # Question Category
    $ rake "crudify:crudify_model[name=txt&order=txt&questions_count=txt,QuestionCategory,name]"
   # Question Section
    $ rake "crudify:crudify_model[name=txt&order=txt&question_category_id=txt,QuestionSection,name]"
   # Procedures
    $ rake "crudify:crudify_model[name=txt&department_id=txt&internal_name=txt,Procedure,name]"
   # Procedure Modifier
    $ rake "crudify:crudify_model[procedure_id=txt&modifier_type=enum&value=txt&modifier_identifier=txt&is_own_product=txtf,ProcedureModifier,modifier_identifier]"

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/crudify. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/crudify/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).