Forem.user_class = "User"
Forem.email_from_address = "foodsoft@foodcoop1040.at"
Forem.per_page = 20
Forem.moderate_first_post = false

Rails.application.config.to_prepare do
  Forem::ApplicationController.layout "forem"
end
