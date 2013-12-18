# optional test coverage
# needs to be loaded first, e.g. add a require at top of spec_helper
if ENV['COVERAGE'] or ENV['COVERALLS']
  require 'simplecov'

  # update coveralls.io on Travis CI
  if ENV['COVERALLS']
    require 'coveralls'
    SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  end

  # slightly tweaked coverage reporting
  def cov_no_plugins(source_file, path)
    source_file.filename =~ /#{path}/ and not source_file.filename =~ /\/lib\/foodsoft_.*\//
  end
  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/test/'
    add_group 'Models'       do |s| cov_no_plugins s, '/app/models/' end
    add_group 'Controllers'  do |s| cov_no_plugins s, '/app/controllers/' end
    add_group 'Helpers'      do |s| cov_no_plugins s, '/app/helpers/' end
    add_group 'Documents'    do |s| cov_no_plugins s, '/app/documents/' end
    add_group 'Libraries'    do |s| cov_no_plugins s, '/lib/' end
    add_group 'Plugins'      do |s| s.filename =~ /\/lib\/foodsoft_.*\// end
  end
end
