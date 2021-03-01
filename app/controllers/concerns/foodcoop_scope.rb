# Controller concern to handle foodcoop scope
#
# Includes a +before_action+ for selecting foodcoop from url.
#
module Concerns::FoodcoopScope
  extend ActiveSupport::Concern

  included do
    prepend_before_action :select_foodcoop
  end

  private

  # Set config and database connection for each request
  # It uses the subdomain to select the appropriate section in the config files
  # Use this method as a before filter (first filter!) in ApplicationController
  def select_foodcoop
    return unless FoodsoftConfig[:multi_coop_install]

    foodcoop = params[:foodcoop]
    if foodcoop.blank?
      FoodsoftConfig.select_default_foodcoop
      redirect_to root_url
    elsif FoodsoftConfig.allowed_foodcoop? foodcoop
      FoodsoftConfig.select_foodcoop foodcoop
    else
      raise ActionController::RoutingError.new 'Foodcoop Not Found'
    end
  end

  # Always stay in foodcoop url scope
  def default_url_options(options = {})
    super().merge({ foodcoop: FoodsoftConfig.scope })
  end
end
