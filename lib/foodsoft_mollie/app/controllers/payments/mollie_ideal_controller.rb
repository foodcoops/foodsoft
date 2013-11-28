#
# This is a quick hack to get iDEAL payments working without modifying
# foodsoft's database model. Transactions are not stored while in process,
# only on success. Failed transactions leave no trace in the database,
# but they are logged in the server log.
#
# Mollie's check url that is used contains the userid as the last path
# component, so that a financial transaction can be created on success
# for that user and ordergroup.
#
# Perhaps a cleaner approach would be to create a financial transaction
# without amount zero when the payment process starts, and keep track
# of the state using that. Then the transaction id would be enough to
# process it, and also an error message could be given.
#
# Or start using activemerchant - e.g.
#   https://github.com/moneybird/active_merchant_mollie
#
class Payments::MollieIdealController < ApplicationController
  skip_before_filter :authenticate, :only => [:check]

  def new
    @banks = IdealMollie.banks
    @amount = params[:amount]
  end

  def create
    bank_id = params[:bank_id]
    amount = params[:amount].to_f

    IdealMollie::Config.return_url = result_payments_mollie_url
    IdealMollie::Config.report_url = check_payments_mollie_url(:id => @current_user.id)
    request = IdealMollie.new_order((amount*100.0).to_i, @current_user.nick, bank_id)

    transaction_id = request.transaction_id
    logger.info "iDEAL start: #{amount} for #{@current_user.nick} with bank #{bank_id}"

    redirect_to request.url
  end

  def check
    transaction_id = params[:transaction_id]
    response = IdealMollie.check_order(transaction_id)
    logger.info "iDEAL check: #{response.inspect}"

    if response.paid
      user = User.find(params[:id])
      notice = self.ideal_note(transaction_id)
      amount = response.amount/100.0
      @transaction = FinancialTransaction.new(:user=>user, :ordergroup=>user.ordergroup, :amount=>amount, :note=>notice)
      @transaction.add_transaction!
    end
    render :nothing => true
  end

  def result
    transaction_id = params[:transaction_id]
    @transaction = FinancialTransaction.where(:note => self.ideal_note(transaction_id)).first
    if @transaction
      logger.info "iDEAL result: transaction #{transaction_id} succeeded"
      redirect_to root_path, :notice => I18n.t('payments.mollie_ideal.controller.result.notice')
    else
      logger.info "iDEAL result: transaction #{transaction_id} failed"
      redirect_to new_payments_mollie_path, :alert => I18n.t('payments.mollie_ideal.controller.result.failed') # TODO recall check's response.message
    end
  end

  protected
  def ideal_note(transaction_id)
    # this is _not_ translated, because this exact string is used to find the transaction
    "iDEAL payment (Mollie #{transaction_id})"
  end
end
