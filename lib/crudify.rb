# frozen_string_literal: true


require "active_support/dependencies"

require 'crudify/engine'
require_relative "crudify/version"

module Crudify
  class Error < StandardError; end
  # Your code goes here...


  def self.mounted_path
    ::Crud::Engine.mounted_path
  end

end
