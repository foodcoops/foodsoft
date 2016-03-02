# encoding: utf-8
class Finance::FinancialTransactionsController < ApplicationController
  before_filter :authenticate_finance
  before_filter :find_ordergroup, :except => [:new_collection, :create_collection, :index_collection]
  inherit_resources
#  belongs_to :ordergroup

  def index
    if params['sort']
      sort = case params['sort']
               when "date"  then "created_on"
               when "note"   then "note"
               when "amount" then "amount"
               when "date_reverse"  then "created_on DESC"
               when "note_reverse" then "note DESC"
               when "amount_reverse" then "amount DESC"
               end
    else
      sort = "created_on DESC"
    end

    @q = FinancialTransaction.search(params[:q])
    @financial_transactions_all = @q.result(distinct: true).includes(:user).order(sort)
    @financial_transactions_all = @financial_transactions_all.where(ordergroup_id: @ordergroup.id) if @ordergroup
    @financial_transactions = @financial_transactions_all.page(params[:page]).per(@per_page)

    respond_to do |format|
      format.js; format.html { render }
      format.csv do
        send_data FinancialTransactionsCsv.new(@financial_transactions_all).to_csv, filename: 'transactions.csv', type: 'text/csv'
      end
    end
  end

  def index_collection
    index
  end

  def new
    @financial_transaction = @ordergroup.financial_transactions.build
    @financial_transaction.financial_transaction_type = FinancialTransactionType.first
    unless params[:bank_transaction_id].nil?
      @bank_transaction = BankTransaction.find(params[:bank_transaction_id])
      @financial_transaction.amount = @bank_transaction.amount
    end
  end

  def create
    @financial_transaction = FinancialTransaction.new(params[:financial_transaction])
    @financial_transaction.user = current_user
    @financial_transaction.money_transfer = BankTransaction.find(params[:bank_transaction_id]).money_transfer_autocreate unless params[:bank_transaction_id].nil?
    @financial_transaction.add_transaction!
    redirect_to finance_ordergroup_transactions_url(@ordergroup), notice: I18n.t('finance.financial_transactions.controller.create.notice')
  rescue ActiveRecord::RecordInvalid => error
    flash.now[:alert] = error.message
    render :action => :new
  end

  def new_collection
    unless params[:bank_transaction_id].nil?
      @bank_transaction = BankTransaction.find(params[:bank_transaction_id])
    end
  end

  def create_collection
    raise I18n.t('finance.financial_transactions.controller.create_collection.error_note_required') if params[:note].blank?
    type = FinancialTransactionType.find_by_id(params[:type])
    type = FinancialTransactionType.first if type.nil?
    money_transfer = BankTransaction.find(params[:bank_transaction_id]).money_transfer_autocreate unless params[:bank_transaction_id].nil?
    params[:financial_transactions].each do |trans|
      # ignore empty amount fields ...
      unless trans[:amount].blank?
        Ordergroup.find(trans[:ordergroup_id]).add_financial_transaction!(trans[:amount], params[:note], @current_user, type, money_transfer)
      end
    end
    redirect_to finance_ordergroups_url, notice: I18n.t('finance.financial_transactions.controller.create_collection.notice')
  rescue => error
    redirect_to finance_new_transaction_collection_url, alert: I18n.t('finance.financial_transactions.controller.create_collection.alert', error: error.to_s)
  end

  protected

  def find_ordergroup
    @ordergroup = Ordergroup.find(params[:ordergroup_id])
  end

end
