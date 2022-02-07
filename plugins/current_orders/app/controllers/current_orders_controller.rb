class CurrentOrdersController < ApplicationController
  before_action :authenticate_orders
end
