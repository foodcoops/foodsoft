module Api::Errors
  class Error < StandardError; end
  # Authentication is handled by Doorkeeper, so no errors for that here
  class PermissionRequired < Error; end
end
