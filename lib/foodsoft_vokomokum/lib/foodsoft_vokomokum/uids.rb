# FoodsoftVokomokum auto-creates users and ordergroups when a user logs
# in using a session cookie from the Vokomokum members system.
# Vokomokum works with a member id, and we'd like foodsoft to have the
# same member id for both the user and ordergroup. To allow the creation
# of (system) users and groups, the starting id is set to a high number
# that is not expected to be reached by Vokomokum.

module FoodsoftVokomokum

  module IncreaseStartId

    def self.included(base) # :nodoc:
      base.class_eval do

        @@_id_offset = 20000
        @@_id_cls = self.class

        # when creating a new record, start at the offset by default
        before_create do
          self.id = [@@_id_offset, @@_id_cls.maximum(:id) + 1].max if self.id.nil?
        end

      end
    end
  end

end

ActiveSupport.on_load(:after_initialize) do
  User.send :include, FoodsoftVokomokum::IncreaseStartId

  Workgroup.send :include, FoodsoftVokomokum::IncreaseStartId
  Workgroup.class_variable_set '@@_id_cls', Group

  Ordergroup.send :include, FoodsoftVokomokum::IncreaseStartId
  Ordergroup.class_variable_set '@@_id_cls', Group
end
