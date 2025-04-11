module Concerns::Locale
  extend ActiveSupport::Concern

  included do
    before_action :set_locale
  end

  def explicitly_requested_language
    params[:locale]
  end

  def user_settings_language
    current_user&.locale
  end

  def session_language
    session[:locale]
  end

  def browser_language
    request.env['HTTP_ACCEPT_LANGUAGE']&.scan(/^[a-z]{2}/)&.first
  end

  def default_language
    FoodsoftConfig[:default_locale] || ::I18n.default_locale
  end

  private

  def select_language_according_to_priority
    language = explicitly_requested_language || session_language || user_settings_language
    language ||= browser_language unless FoodsoftConfig[:ignore_browser_locale]
    language.presence&.to_sym if language.present?
  end

  def available_locales
    ::I18n.available_locales
  end

  def set_locale
    ::I18n.locale = if available_locales.include?(select_language_according_to_priority)
                      select_language_according_to_priority
                    else
                      default_language
                    end

    locale = session[:locale] = ::I18n.locale
    logger.info("Set locale to #{locale}")
  end
end
