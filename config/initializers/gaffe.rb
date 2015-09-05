if Rails.env.production? || Rails.env.staging?
  Gaffe.configure do |config|
    config.errors_controller = 'ErrorsController'
  end
  Gaffe.enable!
end
