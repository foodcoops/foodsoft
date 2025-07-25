# Mollie payment page
#
# ! NOTE Currently ONLY iDEAL is supported, All other methods supported by Mollie are ignored. Even when the account has them enabled
#
# TODO: add support for SEPA bank transfer
# TODO: add support for Credit Cards

class Payments::MollieController < ApplicationController
  include MollieHelper

  before_action -> { require_plugin_enabled FoodsoftMollie }
  skip_before_action :authenticate, only: [:check]
  skip_before_action :verify_authenticity_token, only: [:check]
  before_action :validate_ordergroup_presence, only: %i[new create result]
  before_action :available_payment_methods, only: %i[new create]

  #
  # Called when a new mollie payment is started and page is opened
  #
  # @return [hash] list of available payment methods with amount and fee (currently limited to iDEAL only)
  #
  def new
    params.permit(:amount, :min)
    # if amount or minimum is given use that, otherwise use a default based on the ordergroups funds or amount defined
    @amount = [params[:min], params[:amount]].compact.max || [FoodsoftMollie.default_amount, @ordergroup.get_available_funds * -1].max # @TODO: extract
    params[:min] = params[:amount].to_f > 0 && params[:min].to_f < params[:amount].to_f ? params[:amount] : FoodsoftMollie.default_amount
    logger.debug ">>> Method: #{@available_payment_methods['ideal'].id} Params: #{FoodsoftMollie.default_amount} => #{params[:min]} - #{params[:amount]}}"

    # TODO: support looping and collecting available_payment_methods. For now only iDEAL is supported
    @fee = payment_fee(@available_payment_methods['ideal'], @amount)
    payment = { description: @available_payment_methods['ideal'].description, amount: @amount, fee: @fee }
    @payment_options = { ideal: payment }
    logger.debug "Collected: #{@payment_options}"
  end

  #
  # Create new payment, based on choice made
  #
  def create
    # store parameters so we can redirect to original form on problems
    session[:mollie_params] = params.permit(:amount, :payment_method, :label, :title, :fixed, :min, :text)
    # Check if given amount has not been lowered below minimal allowed amount
    redirect_on_error(t('.invalid_amount', currency: t('number.currency.format.unit'), amount: params[:amount], minimum: params[:min])) and return if params[:min].to_f > params[:amount].to_f

    logger.debug ">>>> #{params[:payment_method]} with #{params[:amount]}"

    @method_chosen = @available_payment_methods[params[:payment_method]]
    redirect_on_error(t('.invalid_method', method: params[:payment_method])) and return if @method_chosen.nil?

    # Fee calculated over the amount to pay
    fee = payment_fee(@method_chosen, params[:amount])
    # Create simplified hash for payment info
    @payment_info = { id: params[:payment_method], description: @method_chosen.description, amount: params[:amount], fee: fee }

    # Create transaction record
    transaction = create_transaction(@payment_info)
    # Execute the payment command
    mollie_payment = create_payment(transaction)
    # Execute the transaction with the returned payment.id from Mollie.
    transaction.update payment_id: mollie_payment.id
    logger.info "Mollie start: #{mollie_payment.id} - Amount: #{@payment_info[:amount].to_f + @payment_info[:fee].to_f} for ##{@current_user.id} (#{@current_user.display})"
    redirect_to mollie_payment.checkout_url, allow_other_host: true
  rescue Mollie::Exception => e
    Rails.logger.info "Mollie reported an error: #{e}"
    redirect_on_error t('errors.general_msg', msg: e.message)
  end

  #
  # Endpoint that Mollie calls when a payment status changes.
  # See: https://docs.mollie.com/overview/webhooks
  #
  # @return handle succesful transaction | report Mollie error on failure
  #
  def check
    logger.debug "MOLLIE check #{params.require(:id)}"
    transaction = FinancialTransaction.find_by_payment_plugin_and_payment_id!('mollie', params.require(:id))
    render plain: update_transaction(transaction)
  rescue StandardError => e
    Rails.logger.error "Mollie check error: #{e}"
    render plain: "Error: #{e.message}"
  end

  # User is redirect here after payment
  def result
    transaction = @ordergroup.financial_transactions.find(params.require(:id))
    logger.debug "MOLLIE result #{params.require(:id)}\nTRANSACTiON PROCESSED #{transaction.inspect}"
    update_transaction transaction
    case transaction.payment_state
    when 'paid'
      redirect_to root_path, notice: t('.controller.result.notice', amount: "#{transaction.payment_currency} #{format('%.2f', transaction.payment_amount)}")
    when 'open', 'pending'
      redirect_to root_path, notice: t('.controller.result.wait')
    when 'canceled'
      redirect_on_error t('.controller.result.canceled')
    else
      redirect_on_error t('.controller.result.failed')
    end
  end

  def cancel
    redirect_to root_path, notice: t('.controller.result.canceled')
  end

  private

  #
  # <Description>
  #
  # @return [<Type>] <description>
  #
  def validate_ordergroup_presence
    @ordergroup = current_user.ordergroup.presence
    redirect_to root_path, alert: t('.no_ordergroup') and return if @ordergroup.nil?
  end

  #
  # <Description>
  #
  # @param [Hash] payment_info All payment info, type, amount and fee
  #
  # @return [FinancialTransaction] Trancaction
  #
  def create_transaction(payment_info)
    logger.debug payment_info.inspect.to_s
    financial_transaction_type = FinancialTransactionType.find_by_id(FoodsoftConfig[:mollie][:financial_transaction_type]) || FinancialTransactionType.first
    note = t('.controller.transaction_note', method: payment_info[:description])
    FinancialTransaction.create!(
      amount: nil,
      ordergroup: @ordergroup,
      user: @current_user,
      payment_plugin: 'mollie',
      payment_amount: payment_info[:amount], # TODO: unclear whether this attribute is used? As the paid amount seems to be copied to `amount`
      payment_fee: payment_info[:fee],
      payment_currency: FoodsoftMollie.currency,
      payment_state: 'open',
      payment_method: payment_info[:id],
      financial_transaction_type: financial_transaction_type,
      note: note
    )
  end

  #
  # Query Mollie status and update financial transaction status
  #
  # @param [FinancialTransaction] transaction
  #
  # TODO: Check how data is stored. It seems confusing and error prone that the balance is recorded seperatly instead of taken from the existing data. See ordergroep.rb|update_balance
  def update_transaction(transaction)
    payment = Mollie::Payment.get(transaction.payment_id, api_key: FoodsoftMollie.api_key)
    logger.debug ">>>>>>> \n\nMollie update_transaction: #{transaction.inspect}\n\n with payment:\n #{payment.inspect} \n => #{payment.status}"
    transaction.update! amount: payment.amount.value.to_f - transaction.payment_fee if FoodsoftMollie.charge_fees? && payment.status == 'paid'
    transaction.update! payment_state: payment.status
  end

  #
  # Execute the Mollie payment transaction
  #
  # @param [FinancialTransaction] transaction All information for the transaction
  #
  # @return [Mollie::Payment] Mollie payment object
  #
  def create_payment(transaction)
    logger.debug ">> #{transaction.inspect}"
    full_amount_due = transaction.payment_amount + transaction.payment_fee
    logger.debug "Create Payment #{full_amount_due} with #{transaction.payment_method} to #{FoodsoftMollie.callback_url}"

    Mollie::Payment.create(
      amount: {
        value: format('%.2f', full_amount_due),
        currency: FoodsoftMollie.currency
      },
      method: transaction.payment_method,
      description: t('.controller.decription', coop: FoodsoftConfig[:name], ordergroup: @ordergroup.name),
      # In case Mollie testing callback is defined, use that one.
      redirectUrl: FoodsoftMollie.callback_url.nil? ? result_payments_mollie_url(id: transaction.id) : "#{FoodsoftMollie.callback_url}/:foodcoop/payments/mollie/result?id=#{transaction.id}",
      webhookUrl: FoodsoftMollie.callback_url.nil? ? check_payments_mollie_url : "#{FoodsoftMollie.callback_url}/:foodcoop/payments/mollie/check",
      metadata: {
        scope: FoodsoftConfig.scope,
        transaction_id: transaction.id,
        user: @current_user.id,
        ordergroup: @ordergroup.id
      },
      api_key: FoodsoftMollie.api_key
    )
  end

  def redirect_on_error(alert_message)
    pms = { foodcoop: FoodsoftConfig.scope }.merge((session[:mollie_params] || {}))
    session[:mollie_params] = nil
    redirect_to new_payments_mollie_path(pms), alert: alert_message
  end

  #
  # Retrieve all supported payment methodes for the Mollie account
  # Uses low-level cache so minimize repeated calls to this very expensive call
  # Expire in 24 hours (not many changes are normally expected)
  #
  # @return [<List>] All allowed payment methods on the account
  #
  def available_payment_methods
    logger.debug "From cache: #{Rails.cache.read(FoodsoftMollie.api_key)}"
    # For development: `rails dev:cache`
    @available_payment_methods = Rails.cache.fetch(FoodsoftMollie.api_key, expires_in: 1.day) do
      retrieve_payment_methods
    end
    logger.debug "MOLLIE TOTAL methods available: #{@available_payment_methods.count}"
  end

  #
  # Calculate fee, when applicable
  #
  # @param [Hash] method Mollie payment method
  # @param [string] amount The payable amount to calculate the fee for
  #
  # @return [float] The fee due
  #

  # Disable as the implicit "return last assignment" mantra breaks the actual function logic
  # rubocop:disable Style/RedundantReturn
  def payment_fee(method, amount)
    return unless FoodsoftMollie.charge_fees?

    # Calculate when fees are charged (otherwise the recipient/coop pays the fee)
    fee = method.pricing[0].fixed.value.to_f + (amount.to_f * (method.pricing[0].variable.to_f / 100))
    ## Add tax (split for clarity)
    fee_with_tax = fee + (fee * FoodsoftMollie.tax_for_mollie.to_f / 100).round(2)
    logger.debug "Fee calculated for method #{method.id}: #{fee_with_tax} for amount: #{amount} with tax #{FoodsoftMollie.tax_for_mollie}%"
    # Make sure we explicitly return the fee_with_tax as the logger returns the number of characters - duh
    return fee_with_tax
  end
  # rubocop:enable Style/RedundantReturn

  #
  # Collect ENABLED payment methods for a Mollie account
  #
  # @return [hash] available_payment_methods for the account
  #

  # Disable as the implicit "return last assignment" mantra breaks the actual function logic
  # rubocop:disable Style/RedundantReturn
  def retrieve_payment_methods
    @payment_methods_all = fetch_mollie_methods
    # Check for every method whether the account has it enabled
    @available_payment_methods = {}
    @payment_methods_all.each do |method|
      # TODO: note that currently this only allows iDEAL, others are effectively disabled
      if eligible_mollie_method(method.id)
        # Method is supported, so add to the list
        logger.debug "ADD TO LIST: #{method.inspect}"
        @available_payment_methods[method.id] = method
      end
      logger.debug "MOLLIE Available #{@available_payment_methods.size}"
    end
    # Make sure this is the object we return (and not rely on the Python implicit return)
    return @available_payment_methods
  end
  # rubocop:enable Style/RedundantReturn

  #
  # Retrieve all payment methods on Mollie
  # Due to an API change 04/2025 this is the _only_ function that returns the pricing information, solves #1178
  # Unfortunately this function does not filter on methods active for the account
  #
  # @return [List] List of ALL payment methods supported by Mollie, regardless whether the account has them enabled or not
  #
  def fetch_mollie_methods
    Mollie::Method.all_available(include: 'pricing', api_key: FoodsoftMollie.api_key)
  end

  #
  # Check for eligible payment methods
  # Since Mollie changed its API, this is now needed to filter for methods which are supported by the account
  # A RequestError will indicate not supported or active: those we can ignore
  #
  # @param [string] method_id payment method
  #
  # @return [boolean] true|false supported or not supported
  #
  def eligible_mollie_method(method_id)
    # logger.debug "MOLLIE CHECKING #{method_id}"
    # ! ------------------------------------------------------------------------------------------------------------
    # ! For the time being we only support iDEAL payments. Others need more work to properly support, notably cards.
    # ! ------------------------------------------------------------------------------------------------------------
    unless ['ideal'].include?(method_id)
      logger.info "MOLLIE method [#{method_id}] currently not supported"
      return false
    end
    # Check if method is enabled on account
    begin
      Mollie::Method.get(method_id, api_key: FoodsoftMollie.api_key)
    rescue Mollie::RequestError
      # Either
      # - 404 Not Found (not present on account)
      # - 403 Not enabled on account
      # TODO: Other errors may be present but effectively this payment method is not available
      logger.debug "MOLLIE method [#{method_id}] not active"
    end
    # Method is supported and active on account
    logger.debug "MOLLIE method [#{method_id}] enabled"
  end
end
