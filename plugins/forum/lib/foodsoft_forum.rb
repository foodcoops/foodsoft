require 'foodsoft_forum/engine'

module FoodsoftForum
  # Return whether the forum is used or not.
  # Enabled by default in {FoodsoftConfig} since it used to be part of the foodsoft core.
  def self.enabled?
    FoodsoftConfig[:use_forum]
  end

  module LoadForum
    def self.included(base) # :nodoc:
      base.class_eval do
        def forem_user
          current_user
        end
        helper_method :forem_user
      end

      User.class_eval do
        def forem_admin?
          role_admin?
        end

        def forem_name
          display
        end
      end
    end
  end
end

ActiveSupport.on_load(:after_initialize) do
  ApplicationController.send :include, FoodsoftForum::LoadForum
end
