Gem::Specification.new do |s|
  s.name        = "private_pub"
  s.version     = "1.0.3"
  s.author      = "Ryan Bates"
  s.email       = "ryan@railscasts.com"
  s.homepage    = "http://github.com/ryanb/private_pub"
  s.summary     = "Private pub/sub messaging in Rails."
  s.description = "Private pub/sub messaging in Rails through Faye."

  s.files        = Dir["{app,lib,spec}/**/*", "[A-Z]*", "init.rb"] - ["Gemfile.lock"]
  s.require_path = "lib"

  s.add_dependency 'faye'
  s.add_dependency 'procto'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rspec-its'
  s.add_development_dependency 'mutant-rspec'
  s.add_development_dependency 'jasmine', '~> 2.0'
  s.add_development_dependency 'pry'

  s.rubyforge_project = s.name
  s.required_rubygems_version = ">= 1.3.4"
end
