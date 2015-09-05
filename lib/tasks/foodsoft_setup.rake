require 'stringio'

# put in here all foodsoft tasks
# => :environment loads the environment an gives easy access to the application

module Colors
  def colorize(text, color_code)
    "\033[#{color_code}m#{text}\033[0m"
  end
 
  {
    :black    => 30,
    :red      => 31,
    :green    => 32,
    :yellow   => 33,
    :blue     => 34,
    :magenta  => 35,
    :cyan     => 36,
    :white    => 37
  }.each do |key, color_code|
    define_method key do |text|
      colorize(text, color_code)
    end
  end
end
include Colors

namespace :foodsoft do
  desc "Setup foodsoft"
  task :setup_development do
    puts yellow "This task will help you get your foodcoop running in development."
    setup_bundler
    setup_app_config
    setup_development
    setup_database
    setup_secret_token
    start_mailcatcher
    puts yellow "All done! Your foodcoft should be running smoothly."
    start_server
  end

  namespace :setup do
    desc "Initialize stock configuration"
    task :stock_config do
      setup_app_config
      setup_development
      setup_secret_token
    end
  end
end

def setup_bundler
  puts yellow "Installing bundler if not installed..."
  %x( if [ -z `which bundle` ]; then gem install bundler --no-rdoc --no-ri; fi )
  puts yellow "Executing bundle install..."
  %x( bundle install )
end

def setup_database
  file = 'config/database.yml'
  if ENV['DATABASE_URL']
    puts blue "DATABASE_URL found, please remember to also set it when running Foodsoft"
    return nil
  end
  return nil if skip?(file)
  
  database = ask("What kind of database do you use?\nOptions:\n(1) MySQL\n(2) SQLite", ["1","2"])
  if database == "1"
    puts yellow "Using MySQL..."
    %x( cp #{Rails.root.join("#{file}.MySQL_SAMPLE")} #{Rails.root.join(file)} )
  elsif database == "2"
    puts yellow "Using SQLite..."
    %x( cp #{Rails.root.join("#{file}.SQLite_SAMPLE")} #{Rails.root.join(file)} )
  end
  
  reminder(file)
  
  puts blue "IMPORTANT:  Edit (rake-generated) config/database.yml with valid username and password for EACH env before continuing!"
  finished = ask("Finished?\nOptions:\n(y) Yes", ["y"])
  if finished
    Rake::Task["db:setup"].reenable
    db_setup = capture_stdout { Rake::Task["db:setup"].invoke }
    puts db_setup
  end
end

def setup_app_config
  file = 'config/app_config.yml'
  sample = Rails.root.join("#{file}.SAMPLE")
  return nil if skip?(file)
  
  puts yellow "Copying #{file}..."
  %x( cp #{sample} #{Rails.root.join(file)} )
  reminder(file)
end

def setup_development
  file = 'config/environments/development.rb'
  return nil if skip?(file)
  
  puts yellow "Copying #{file}..."
  %x( cp #{Rails.root.join("#{file}.SAMPLE")} #{Rails.root.join(file)} )
  reminder(file)
end

def setup_secret_token
  file = 'config/initializers/secret_token.rb'
  return nil if skip?(file)
  
  puts yellow "Generating secret_token and writing to #{file}..."
  Rake::Task["secret"].reenable
  secret = capture_stdout { Rake::Task["secret"].invoke }
  %x( touch #{Rails.root.join("#{file}")}; echo 'Foodsoft::Application.config.secret_key_base = "#{secret.chomp}"' > #{Rails.root.join("#{file}")} )
end

def start_mailcatcher
  return nil if ENV['MAILCATCHER_PORT'] # skip when it has an existing Docker container
  mailcatcher = ask("Do you want to start mailcatcher?\nOptions:\n(y) Yes\n(n) No", ["y","n"])
  if mailcatcher === "y"
    puts yellow "Starting mailcatcher at http://localhost:1080..."
    %x( mailcatcher )
  end
end

def start_server
  puts blue "Start your server running 'bundle exec rails s' and visit http://localhost:3000"
end

# Helper Methods

def ask(question, answers = false)
  puts question
  input = STDIN.gets.chomp
  if input.blank? || (answers && !answers.include?(input))
    puts red "Your Input is not valid. Try again!"
    input = ask(question, answers)
  end
  input
end

def skip?(file)
  output = false
  skip = ask(cyan("We found #{file}!\nOptions:\n(1) Skip step\n(2) Force rewrite"), ["1","2"]) if File.exists?(Rails.root.join(file))
  output = true if skip == "1"
  output
end

def reminder(file)
  puts blue "don't forget to edit #{file}"
end

def capture_stdout
  s = StringIO.new
  $stdout = s
  yield
  s.string
ensure
  $stdout = STDOUT
end

