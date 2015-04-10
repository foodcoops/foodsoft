# encoding: utf-8
class CurrentOrdersController < ApplicationController
  
  before_filter :authenticate_orders

end
