# encoding: utf-8
class Finance::FinancialTransactionsController < ApplicationController
  before_action :authenticate_finance
  before_action :find_ordergroup, :except => [:new_collection, :create_collection, :index_collection]
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
    @financial_transactions_all = @financial_transactions_all.visible unless params[:show_hidden]
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
  end

  def create
    @financial_transaction = FinancialTransaction.new(params[:financial_transaction])
    @financial_transaction.user = current_user
    @financial_transaction.add_transaction!
    redirect_to finance_ordergroup_transactions_url(@ordergroup), notice: I18n.t('finance.financial_transactions.controller.create.notice')
  rescue ActiveRecord::RecordInvalid => error
    flash.now[:alert] = error.message
    render :action => :new
  end

  def destroy
    transaction = FinancialTransaction.find(params[:id])
    transaction.revert!(current_user)
    redirect_to finance_ordergroup_transactions_url(transaction.ordergroup), notice: t('finance.financial_transactions.controller.destroy.notice')
  end

  def new_collection
  end

  def create_collection
    raise I18n.t('finance.financial_transactions.controller.create_collection.error_note_required') if params[:note].blank?
    type = FinancialTransactionType.find_by_id(params[:type_id])
    financial_link = nil

    ActiveRecord::Base.transaction do
      financial_link = FinancialLink.new if params[:create_financial_link]

      params[:financial_transactions].each do |trans|
        # ignore empty amount fields ...
        unless trans[:amount].blank?
          amount = trans[:amount].to_f
          note = params[:note]
          ordergroup = Ordergroup.find(trans[:ordergroup_id])
          if params[:set_balance]
            note += " (#{amount})"
            amount -= ordergroup.financial_transaction_class_balance(type.financial_transaction_class)
          end
          ordergroup.add_financial_transaction!(amount, note, @current_user, type, financial_link)
        end
      end

      financial_link.try(&:save!)
    end

    url = financial_link ? finance_link_url(financial_link.id) : finance_ordergroups_url
    redirect_to url, notice: I18n.t('finance.financial_transactions.controller.create_collection.notice')
  rescue => error
    flash.now[:alert] = error.message
    render action: :new_collection
  end

  protected

  def find_ordergroup
    @ordergroup = Ordergroup.include_transaction_class_sum.find(params[:ordergroup_id])
  end

end
