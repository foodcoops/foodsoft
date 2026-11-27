module Pickup
  # Auth for the pickup API: doorkeeper bearer tokens, nothing else.
  #
  # Everything the machinery in Concerns::AuthApi and Api::BaseController
  # provides -- token -> current_user, scope -> role checks, error rendering --
  # is inherited; this only turns off the session so an app request cannot
  # touch cookies, and adds the gate that switches the API off per foodcoop.
  class BaseController < Api::BaseController
    before_action :verify_enabled!

    private

    def verify_enabled!
      return if FoodsoftPickup.enabled?

      raise Api::Errors::PermissionRequired, 'Forbidden, pickup api not enabled'
    end
  end
end
