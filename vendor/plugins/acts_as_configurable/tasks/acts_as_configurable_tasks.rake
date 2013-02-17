require 'rake/testtask'
#require 'rake/rdoctask'

namespace :test do
  desc "run the acts as configurable test suite"
  task :acts_as_configurable do
    Rake::TestTask.new(:aac_test) do |t|
      t.libs << File.join(File.dirname(__FILE__), '/../lib')
      t.pattern = File.join(File.dirname(__FILE__), '/../test/**/*_test.rb')
      t.verbose = true
    end
    Rake::Task[:aac_test].invoke
  end
end

namespace :doc do
  desc "generate the acts as configurable rdoc files"
  task :acts_as_configurable do
    Rake::RDocTask.new(:aac_rdoc) do |rdoc|
      rdoc.rdoc_dir = File.join(File.dirname(__FILE__), '/../rdoc')
      rdoc.title    = 'Acts As Configurable'
      rdoc.options << '--line-numbers' << '--inline-source'
      rdoc.rdoc_files.include(File.join(File.dirname(__FILE__), '/../README'))
      rdoc.rdoc_files.include(File.join(File.dirname(__FILE__), '/../lib/**/*.rb'))
    end
    Rake::Task[:aac_rdoc].invoke
  end
end