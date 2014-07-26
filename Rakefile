require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'
require 'jasmine'
load 'jasmine/tasks/jasmine.rake'

desc "Run RSpec"
RSpec::Core::RakeTask.new do |t|
  t.verbose = false
end

task :mutant do
  system("bundle exec mutant -I lib -r private_pub --use rspec 'PrivatePub*'")
end

task :default => [:spec, "jasmine:ci"]