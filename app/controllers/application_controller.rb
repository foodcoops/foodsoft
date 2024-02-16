class ApplicationController < ActionController::Base
  include Concerns::FoodcoopScope
  include Concerns::Auth
  include Concerns::Locale
  include PathHelper
  helper_method :current_user
  helper_method :available_locales

  protect_from_forgery
  before_action :authenticate, :set_user_last_activity, :store_controller, :items_per_page
  after_action  :remove_controller
  around_action :set_time_zone, :set_currency

  # needed for linking to attachments on locals storage 
  before_action do
    ActiveStorage::Current.url_options = { protocol: request.protocol, host: request.host, port: request.port }
  end

  # Returns the controller handling the current request.
  def self.current
    Thread.current[:application_controller]
  end

  private

  def set_user_last_activity
    return unless current_user && (session[:last_activity].nil? || session[:last_activity] < 1.minute.ago)

    current_user.update_attribute(:last_activity, Time.now)
    session[:last_activity] = Time.now
  end

  # Many plugins can be turned on and off on the fly with a `use_` configuration option.
  # To disable a controller in the plugin, you can use this as a `before_action`:
  #
  #     class MypluginController < ApplicationController
  #       before_action -> { require_plugin_enabled FoodsoftMyplugin }
  #     end
  #
  def require_plugin_enabled(plugin)
    redirect_to_root_with_feature_disabled_alert unless plugin.enabled?
  end

  def require_config_enabled(config)
    redirect_to_root_with_feature_disabled_alert unless FoodsoftConfig[config]
  end

  def require_config_disabled(config)
    redirect_to_root_with_feature_disabled_alert if FoodsoftConfig[config]
  end

  def redirect_to_root_with_feature_disabled_alert
    redirect_to root_path, alert: I18n.t('application.controller.error_feature_disabled')
  end

  # Stores this controller instance as a thread local varibale to be accessible from outside ActionController/ActionView.
  def store_controller
    Thread.current[:application_controller] = self
  end

  # Sets the thread local variable that holds a reference to the current controller to nil.
  def remove_controller
    Thread.current[:application_controller] = nil
  end

  # Get supplier in nested resources
  def find_supplier
    @supplier = Supplier.find(params[:supplier_id]) if params[:supplier_id]
  end

  def items_per_page
    @per_page = if params[:per_page] && params[:per_page].to_i > 0 && params[:per_page].to_i <= 500
                  params[:per_page].to_i
                else
                  20
                end
  end

  # Set timezone according to foodcoop preference.
  # @see http://stackoverflow.com/questions/4362663/timezone-with-rails-3
  # @see http://archives.ryandaigle.com/articles/2008/1/25/what-s-new-in-edge-rails-easier-timezones
  def set_time_zone
    old_time_zone = Time.zone
    Time.zone = FoodsoftConfig[:time_zone] if FoodsoftConfig[:time_zone]
    yield
  ensure
    Time.zone = old_time_zone
  end

  # Set currency according to foodcoop preference.
  # @see #set_time_zone
  def set_currency
    old_currency = ::I18n.t('number.currency.format.unit')
    new_currency = FoodsoftConfig[:currency_unit] || ''
    new_currency += "\u202f" if FoodsoftConfig[:currency_space]
    ::I18n.backend.store_translations(::I18n.locale, number: { currency: { format: { unit: new_currency } } })
    yield
  ensure
    ::I18n.backend.store_translations(::I18n.locale, number: { currency: { format: { unit: old_currency } } })
  end
end
