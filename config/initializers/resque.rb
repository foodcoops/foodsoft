# Initializer to configure resque daemon
Resque.redis = ENV.fetch("REDIS_URL", "redis://localhost:6379")
