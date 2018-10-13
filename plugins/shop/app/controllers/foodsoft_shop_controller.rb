class FoodsoftShopController < ApplicationController
  before_filter -> { require_plugin_enabled FoodsoftShop }
  before_filter :ensure_ordergroup_member

  DOORKEEPER_APP_NAME = FoodsoftShop::DOORKEEPER_APP_NAME

  def index
    @foodsoft_url = root_url
    @foodsoft_client_id = client_id
    render layout: false
  end

  private

  def doorkeeper_app
    @app ||= begin
      # Find Doorkeeper Application
      Doorkeeper::Application.find_or_create_by!(name: DOORKEEPER_APP_NAME) do |app|
        app.redirect_uri = foodsoft_shop_url
        app.confidential = false # implicit flow does not use a secret
      end.tap do |app|
        # Make sure the redirect-url is up-to-date (e.g. after a domain name change)
        redirect_uris = app.redirect_uri.split
        unless redirect_uris.include?(foodsoft_shop_url)
          app.update_attributes!(redirect_uri: redirect_uris + [foodsoft_shop_url])
        end
      end
    end
  end

  def client_id
    doorkeeper_app.uid
  end

  # @see GroupOrdersController#ensure_ordergroup_member
  def ensure_ordergroup_member
    unless @current_user.ordergroup.present?
      redirect_to root_url, :alert => I18n.t('group_orders.errors.no_member')
    end
  end
end
