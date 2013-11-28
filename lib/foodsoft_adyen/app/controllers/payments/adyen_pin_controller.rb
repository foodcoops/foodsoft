require 'base64'

class Payments::AdyenPinController < ApplicationController
  before_filter :find_ordergroup
  layout 'adyen_mobile'

  # show list of ordergroups
  def index
    @ordergroups = Ordergroup.undeleted
    @ordergroups = @ordergroups.where('name LIKE ?', "%#{params[:query]}%") unless params[:query].nil?
    @ordergroups = @ordergroups.page(params[:page]).per(@per_page)
  end

  # show form for initiating a new payment
  def new
    #@adyen_pin_url = adyen_pin_url(@ordergroup.id, 4.99, 'hi there')
    create
  end

  # initiate pin payment using Adyen app
  def create
    redirect_to adyen_pin_url(@ordergroup, @ordergroup.get_available_funds)
  end

  # callback url after payment
  def created
    index
    render :index
  end


  protected

  def find_ordergroup
    @ordergroup = Ordergroup.find(params[:ordergroup_id]) rescue nil
  end
  

  private

  def adyen_pin_url(ordergroup, amount)
    opts = {
      currency: Rails.configuration.foodsoft_adyen.currency,
      amount: (amount * 100).to_i,
      description: encode_notification_data({g: ordergroup.id}, ordergroup.name),
      callback: created_payments_adyen_pin_url(:ordergroup_id => ordergroup.id), # or use opt sessionId
      callbackAutomatic: 0,
      start_immediately: true
    }
    if request.user_agent.match '\bAndroid\b'
      return "http://www.adyen.com/android-app/payment?#{opts.to_query}"
    else #elsif request.user_agent.match '\b(iPod|iPhone|iPad)\b'
      return "adyen://payment?#{opts.to_query}"
    end
  end

  def encode_notification_data(data, title=nil)
    d = Base64.urlsafe_encode64 data.to_json
    return [title, "(#{d})"].compact.join(' ')
  end

end
