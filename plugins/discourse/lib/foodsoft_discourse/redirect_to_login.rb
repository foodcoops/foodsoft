module FoodsoftDiscourse

  module RedirectToLogin
    def self.included(base) # :nodoc:
      base.class_eval do

        alias orig_redirect_to_login redirect_to_login

        def redirect_to_login(options={})
          return orig_redirect_to_login(options) unless FoodsoftDiscourse.enabled?
          redirect_to discourse_initiate_path
        end

      end
    end
  end

end

# modify existing helper
ActiveSupport.on_load(:after_initialize) do
  ApplicationController.send :include, FoodsoftDiscourse::RedirectToLogin
end
