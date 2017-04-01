# Initializer to configure resque daemon
Resque.redis = ENV['REDIS_URL'] if ENV['REDIS_URL']
