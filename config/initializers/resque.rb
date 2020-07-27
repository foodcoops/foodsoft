# Initializer to configure resque daemon
if Rails.env.test?
  Resque.inline = true
elsif ENV['REDIS_URL']
  Resque.redis = ENV['REDIS_URL']
else
  puts 'WARNING: redis is not installed, so Resque is using inline method.  (not recommended for production)'
  Resque.inline = true
end
