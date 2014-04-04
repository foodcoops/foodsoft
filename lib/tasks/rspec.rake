begin
  require 'rspec/core/rake_task'
  task(:spec).clear
  RSpec::Core::RakeTask.new(:spec)
  task :default => :spec

  # Use `rspec` to run a single test. When a test fails in rake but not
  # with rspec, you can use the following to run a single test using rake:
  #RSpec::Core::RakeTask.new('spec:foo') do |t|
  #  t.pattern = "spec/integration/foo_spec.rb"
  #end
rescue LoadError
end
