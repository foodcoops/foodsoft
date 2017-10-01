# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
Foodsoft::Application.config.secret_key_base = begin
  if (token = ENV['SECRET_KEY_BASE']).present?
    token
  elsif Rails.env.production? || Rails.env.staging?
    raise "You must set SECRET_KEY_BASE"
  elsif Rails.env.test?
    SecureRandom.hex(30) # doesn't really matter
  else
    sf = Rails.root.join('tmp', 'secret_key_base')
    if File.exists?(sf)
      File.read(sf)
    else
      puts "=> Generating initial SECRET_KEY_BASE in #{sf}"
      token = SecureRandom.hex(30)
      File.open(sf, 'w') { |f| f.write(token) }
      token
    end
  end
end
