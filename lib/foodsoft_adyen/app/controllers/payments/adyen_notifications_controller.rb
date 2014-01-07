require 'base64'

class Payments::AdyenNotificationsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:notify]
  skip_before_filter :authenticate, :only => [:notify]
  before_filter :authenticate_adyen, :only => [:notify]

  class WrongCurrencyException < Exception; end
  class OrdergroupNotFoundException < Exception; end
  class NotificationDataException < Exception; end

  def notify
    notification = AdyenNotification.log(params)
    logger.debug 'foodsoft_adyen: notify'
    if notification.successful_authorisation?
      data = decode_notification_data(notification.merchant_reference)
      logger.debug "foodsoft_adyen: new notification with data #{data.inspect}"
      (ordergroup = Ordergroup.find(data[:g])) rescue raise OrdergroupNotFoundException
      notification.currency == Rails.configuration.foodsoft_adyen.currency or raise WrongCurrencyException
      notice = "#{notification.payment_method} payment (Adyen #{notification.psp_reference})"
      amount = notification.value/100.0
      (user = User.new).id = 0 # 0 is system user, may not exist in database
      ordergroup.add_financial_transaction!(amount, notice, user)
      logger.debug 'foodsoft_adyen: handled authorisation notification'
    else
      logger.debug 'foodsoft_adyen: nothing to do'
    end
    ws_return :accepted
  rescue NotificationDataException => e
    ws_return :rejected, "merchant_reference #{e}"
  rescue OrdergroupNotFoundException
    ws_return :rejected, 'merchant_reference does not contain a valid user'
  rescue WrongCurrencyException
    ws_return :rejected, "foodsoft_adyen configuration only accepts currency #{Rails.configuration.foodsoft_adyen.currency}"
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid => e
    # Validation failed, because of the duplicate check.
    # So ignore this notification, it is already stored and handled.
    logger.debug 'foodsoft_adyen: notification already handled, ignoring'
    ws_return :accepted
  rescue Exception => e
    ws_return :error, e
  end

  protected
  def authenticate_adyen
    authenticate_or_request_with_http_basic do |username, password|
      username == Rails.configuration.foodsoft_adyen.notify_username && password == Rails.configuration.foodsoft_adyen.notify_password
    end
  end

  def ws_return(status, msg=nil)
    if status == :rejected
      logger.warn "foodsoft_adyen: #{msg}"
    elsif status == :error
      logger.error msg
      logger.error(Rails.backtrace_cleaner.clean(msg.backtrace).map{|x| "  #{x}"}.join("\n")) if msg.is_a? Exception
    end
    render :text => ("[#{status}]" + (msg.nil? ? '' : " #{msg}"))
  end

  # returns hash of foodsoft data for transaction
  def decode_notification_data(data)
    ActiveSupport::JSON.decode Base64.urlsafe_decode64(data.gsub(/^.*\((.*)\)\s*$/,'\1')), {symbolize_names: true}
  rescue ActiveSupport::JSON.parse_error
    raise NotificationDataException.new('does not contain valid JSON')
  rescue ArgumentError
    raise NotificationDataException.new('is not a URL-safe base64 encoded string (RFC 4648)')
  end

end
