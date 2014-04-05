module FoodsoftMessages

  module UserLink
    def self.included(base) # :nodoc:
      base.class_eval do

        # modify user presentation link to writing a message for the user
        def show_user_link(user=@current_user)
          if user.nil? or not FoodsoftMessages.enabled?
            show_user user
          else
            link_to show_user(user), new_message_path('message[mail_to]' => user.id),
                                    :title => I18n.t('helpers.messages.write_message')
          end
        end

      end
    end
  end

end

# modify existing helper
ActiveSupport.on_load(:after_initialize) do
  ApplicationHelper.send :include, FoodsoftMessages::UserLink
end
