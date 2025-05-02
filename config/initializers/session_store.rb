# Be sure to restart your server when you modify this file.

module ActionDispatch
  module Session
    class SlugCookieStore < CookieStore
      alias orig_set_cookie set_cookie

      def set_cookie(request, session_id, cookie)
        if script_name = FoodsoftConfig[:script_name]
          path = request.original_fullpath[script_name.size..-1]
          slug = path.split('/', 2).first
          return if slug.blank?

          cookie[:path] = script_name + slug
        end
        orig_set_cookie request, session_id, cookie
      end
    end
  end
end

Rails.application.config.session_store :slug_cookie_store, key: '_foodsoft_session', expire_after: 1.year

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Foodsoft::Application.config.session_store :active_record_store
