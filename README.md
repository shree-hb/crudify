# Crudify

The Crudify gem provides a CRUD interface for an existing model in Rails app. 
The model attribute which is needed for CRUD can be configured at the model level.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add crudify

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install crudify

## Usage

Once gem is installed follow below steps

In Routes.rb , Add below line

   $ mount Crudify::Engine => "crudify"

To Generate Initializer, run below rake
  
   $ rake crudify:generate_initializer --trace

To configure model for which CRUD needs to be enabled , run below task (change it with target model name, attribute)

   $ rake "crudify:crudify_model[name=txt&display_name=txt&department_type=txt&country=enum,Department]"

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/crudify. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/crudify/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).