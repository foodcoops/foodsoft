module FoodsoftWiki
  module Mailer
    def self.included(base) # :nodoc:
      base.class_eval do
        # modify user presentation link to writing a message for the user
        def additonal_welcome_text(user)
          if FoodsoftWiki.enabled? && (page = Page.welcome_mail)
            page.body
          end
        end
      end
    end
  end
end

# modify existing helper
ActiveSupport.on_load(:after_initialize) do
  Mailer.send :include, FoodsoftWiki::Mailer
end
