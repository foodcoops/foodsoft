class FoodsoftCache
  require 'redis'
  @@redis = Redis.new
  @@prefix = 'FoodsoftCache:'

  def self.get(key)
    @@redis.get(to_key(key))
  end

  def self.set(key, value)
    @@redis.set(to_key(key), value)
  end

  protected

  def self.to_key(key)
    @@prefix + key
  end
end
