# -*- encoding : utf-8 -*-
module Foodsoft
  module ControllerExtensions
    module Locale
      extend ActiveSupport::Concern

      included do
        before_filter :set_locale
      end

      def explicitly_requested_language
        params[:locale]
      end

      def user_settings_language
        current_user.locale if current_user
      end
      
      def session_language
        session[:locale]
      end

      def browser_language
        request.env['HTTP_ACCEPT_LANGUAGE'] ? request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first : nil
      end

      def default_language
        FoodsoftConfig[:default_locale] or ::I18n.default_locale
      end

      protected

      def select_language_according_to_priority
        language = explicitly_requested_language || session_language || user_settings_language
        language ||= browser_language unless FoodsoftConfig[:ignore_browser_locale]
        language.to_sym unless language.blank?
      end

      def available_locales
        ::I18n.available_locales
      end

      def set_locale
        if available_locales.include?(select_language_according_to_priority)
          ::I18n.locale = select_language_according_to_priority
        else
          ::I18n.locale = default_language
        end

        locale = session[:locale] = ::I18n.locale
        logger.info("Set locale to #{locale}")
      end

    end
  end
end
