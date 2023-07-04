# frozen_string_literal: true

require_relative "lib/crudify/version"

Gem::Specification.new do |spec|
  spec.name = "crudify"
  spec.version = Crudify::VERSION
  spec.authors = ["shree-hb"]
  spec.email = ["107175680+shree-hb@users.noreply.github.com"]

  spec.summary = "A CRUD wrapper for existing models which do not have controller/views "
  spec.description = "A CRUD wrapper for existing models which do not have controller/views "
  spec.homepage = "https://github.com/shree-hb/crudify"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://github.com/shree-hb/crudify"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/shree-hb/crudify"
  spec.metadata["changelog_uri"] = "https://github.com/shree-hb/crudify"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
