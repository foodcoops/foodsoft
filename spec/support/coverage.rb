# optional test coverage
# needs to be loaded first, e.g. add a require at top of spec_helper
if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/test/'
    add_group 'Models', '/app/models/'
    add_group 'Controllers', '/app/controllers/'
    add_group 'Helpers', '/app/helpers/'
    add_group 'Documents', '/app/documents/'
    add_group 'Libraries', '/lib/'
  end
end
