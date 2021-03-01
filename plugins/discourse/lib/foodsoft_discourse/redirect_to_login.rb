module FoodsoftDiscourse
  module RedirectToLogin
    def self.included(base) # :nodoc:
      base.class_eval do
        alias foodsoft_discourse_orig_redirect_to_login redirect_to_login

        def redirect_to_login(options = {})
          if FoodsoftDiscourse.enabled? && !FoodsoftConfig[:discourse_sso]
            redirect_to discourse_initiate_path
          else
            foodsoft_discourse_orig_redirect_to_login(options)
          end
        end
      end
    end
  end
end

# modify existing helper
ActiveSupport.on_load(:after_initialize) do
  Concerns::Auth.send :include, FoodsoftDiscourse::RedirectToLogin
end
