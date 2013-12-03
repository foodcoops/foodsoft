begin
  require 'rspec/core/rake_task'
  task(:spec).clear
  RSpec::Core::RakeTask.new(:spec)
  task :default => :spec
rescue LoadError
end
