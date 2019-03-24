# Initializer to configure resque daemon
if ENV['REDIS_URL']
  Resque.redis = ENV['REDIS_URL']
else
  puts 'WARNING: redis is not installed, so Resque is using inline method.  (not recommended for production)'
  Resque.inline = true
end
