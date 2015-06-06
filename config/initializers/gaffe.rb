if Rails.env.production? || Rails.env.staging? || true
  Gaffe.configure do |config|
    config.errors_controller = 'ErrorsController'
  end
  Gaffe.enable!
end
