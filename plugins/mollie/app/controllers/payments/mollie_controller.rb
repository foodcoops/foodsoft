# Mollie payment page
class Payments::MollieController < ApplicationController
  before_action -> { require_plugin_enabled FoodsoftMollie }
  skip_before_action :authenticate, only: [:check]
  skip_before_action :verify_authenticity_token, only: [:check]
  before_action :validate_ordergroup_presence, only: %i[new create result]
  before_action :payment_methods, only: %i[new create]

  def new
    params.permit(:amount, :min)
    # if amount or minimum is given use that, otherwise use a default based on the ordergroups funds or 10
    @amount = [params[:min], params[:amount]].compact.max || [FoodsoftMollie.default_amount, @ordergroup.get_available_funds * -1].max # @todo extract
  end

  def create
    # store parameters so we can redirect to original form on problems
    session[:mollie_params] = params.permit(:amount, :payment_method, :label, :title, :fixed, :min, :text, :payment_fee)

    amount = [params[:min].to_f, params[:amount].to_f].compact.max
    payment_fee = params[:payment_fee].to_f
    amount += payment_fee

    redirect_on_error(t('.invalid_amount')) and return if amount <= 0

    method = fetch_mollie_methods.find { |m| m.id == params[:payment_method] }
    transaction = create_transaction(amount, payment_fee, method)
    payment = create_payment(transaction, amount, method)
    transaction.update payment_id: payment.id
    logger.info "Mollie start: #{amount} for ##{@current_user.id} (#{@current_user.display})"
    redirect_to payment.checkout_url, allow_other_host: true
  rescue Mollie::Exception => e
    Rails.logger.info "Mollie create warning: #{e}"
    redirect_on_error t('errors.general_msg', msg: e.message)
  end

  # Endpoint that Mollie calls when a payment status changes.
  # See: https://docs.mollie.com/overview/webhooks
  def check
    transaction = FinancialTransaction.find_by_payment_plugin_and_payment_id!('mollie', params.require(:id))
    render plain: update_transaction(transaction)
  rescue StandardError => e
    Rails.logger.error "Mollie check error: #{e}"
    render plain: "Error: #{e.message}"
  end

  # User is redirect here after payment
  def result
    transaction = @ordergroup.financial_transactions.find(params.require(:id))
    update_transaction transaction
    case transaction.payment_state
    when 'paid'
      redirect_to root_path, notice: t('.controller.result.notice', amount: "#{transaction.payment_currency} #{transaction.amount}")
    when 'open', 'pending'
      redirect_to root_path, notice: t('.controller.result.wait')
    else
      redirect_on_error t('.controller.result.failed')
    end
  end

  def cancel
    redirect_to root_path
  end

  private

  # Query Mollie status and update financial transaction
  def update_transaction(transaction)
    payment = Mollie::Payment.get(transaction.payment_id, api_key: FoodsoftMollie.api_key)
    logger.debug "Mollie update_transaction: #{transaction.inspect} with payment: #{payment.inspect}"
    if payment.paid?
      amount = payment.amount.value.to_f
      amount -= transaction.payment_fee if FoodsoftMollie.charge_fees?
      transaction.update! amount: amount
    end
    transaction.update! payment_state: payment.status
  end

  def payment_methods
    @payment_methods = fetch_mollie_methods
    @payment_methods_fees = @payment_methods.to_h do |method|
      next [method.id, []] if method.pricing.blank?

      [method.id, method.pricing.map do |pricing|
        {
          description: pricing.description,
          fixed: { currency: pricing.fixed.currency, value: pricing.fixed.value.to_f },
          variable: pricing.variable.to_f
        }
      end.to_json]
    end
  end

  def validate_ordergroup_presence
    @ordergroup = current_user.ordergroup.presence
    redirect_to root_path, alert: t('.no_ordergroup') and return if @ordergroup.nil?
  end

  def create_transaction(amount, payment_fee, method)
    financial_transaction_type = FinancialTransactionType.find_by_id(FoodsoftConfig[:mollie][:financial_transaction_type]) || FinancialTransactionType.first
    note = t('.controller.transaction_note', method: method.description)

    FinancialTransaction.create!(
      amount: nil,
      ordergroup: @ordergroup,
      user: @current_user,
      payment_plugin: 'mollie',
      payment_amount: amount,
      payment_fee: payment_fee,
      payment_currency: FoodsoftMollie.currency,
      payment_state: 'open',
      payment_method: method.id,
      financial_transaction_type: financial_transaction_type,
      note: note
    )
  end

  def create_payment(transaction, amount, method)
    Mollie::Payment.create(
      amount: {
        value: format('%.2f', amount),
        currency: FoodsoftMollie.currency
      },
      method: method.id,
      description: "#{FoodsoftConfig[:name]}: Continue to add credit to #{@ordergroup.name}",
      redirectUrl: result_payments_mollie_url(id: transaction.id),
      webhookUrl: request.local? ? 'https://localhost.com' : check_payments_mollie_url, # Workaround for local development
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

  def fetch_mollie_methods
    Mollie::Method.all(include: 'pricing,issuers', amount: { currency: FoodsoftMollie.currency, value: format('%.2f', FoodsoftMollie.default_amount) }, api_key: FoodsoftMollie.api_key)
  end
end
