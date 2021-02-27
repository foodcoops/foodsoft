class Finance::FinancialTransactionsController < ApplicationController
  before_action :authenticate_finance, except: [:create]
  before_action :find_ordergroup, except: %i[new_collection create_collection index_collection]
  before_action :authenticate_finance_or_self_service_and_own_ordergroup, only: [:create]
  inherit_resources
  #  belongs_to :ordergroup

  def index
    sort = if params['sort']
             case params['sort']
             when 'date' then 'created_on'
             when 'note'   then 'note'
             when 'amount' then 'amount'
             when 'date_reverse' then 'created_on DESC'
             when 'note_reverse' then 'note DESC'
             when 'amount_reverse' then 'amount DESC'
             end
           else
             'created_on DESC'
           end

    @q = FinancialTransaction.ransack(params[:q])
    @financial_transactions_all = @q.result(distinct: true).includes(:user).order(sort)
    @financial_transactions_all = @financial_transactions_all.visible unless params[:show_hidden]
    @financial_transactions_all = @financial_transactions_all.where(ordergroup_id: @ordergroup.id) if @ordergroup
    @financial_transactions_all = @financial_transactions_all.where(ordergroup: nil) if @foodcoop
    @financial_transactions = @financial_transactions_all.page(params[:page]).per(@per_page)

    respond_to do |format|
      format.js
      format.html { render }
      format.csv do
        send_data FinancialTransactionsCsv.new(@financial_transactions_all).to_csv, filename: 'transactions.csv',
                                                                                    type: 'text/csv'
      end
    end
  end

  def index_collection
    index
  end

  def new
    @financial_transaction = if @ordergroup
                               @ordergroup.financial_transactions.build
                             else
                               FinancialTransaction.new
                             end
  end

  def create
    @financial_transaction = FinancialTransaction.new(params[:financial_transaction])
    @financial_transaction.user = current_user
    @financial_transaction.save!

    respond_to do |format|
      format.js
      redirect_to finance_group_transactions_path(@ordergroup),
                notice: I18n.t('finance.financial_transactions.controller.create.notice')
    end
  rescue ActiveRecord::RecordInvalid => error
    @error = error
    respond_to do |format|
      format.js
      format.html do
        flash.now[:alert] = error.message
        render :action => :new
      end
    end
  end

  def destroy
    transaction = FinancialTransaction.find(params[:id])
    transaction.revert!(current_user)
    redirect_to finance_group_transactions_path(transaction.ordergroup),
                notice: t('finance.financial_transactions.controller.destroy.notice')
  end

  def new_collection
    @ordergroups = {}
    Ordergroup.undeleted.order(:name).map do |ordergroup|
      obj = { name: ordergroup.name }
      Ordergroup.custom_fields.each do |field|
        obj[field[:name]] = ordergroup.settings.custom_fields[field[:name]]
      end
      @ordergroups[ordergroup.id] = obj
    end
  end

  def create_collection
    raise I18n.t('finance.financial_transactions.controller.create_collection.error_note_required') if params[:note].blank?

    type = FinancialTransactionType.find_by_id(params[:type_id])
    financial_link = nil

    ActiveRecord::Base.transaction do
      financial_link = FinancialLink.new if params[:create_financial_link]
      foodcoop_amount = 0

      params[:financial_transactions].each do |trans|
        # ignore empty amount fields ...
        next if trans[:amount].blank?

        amount = LocalizeInput.parse(trans[:amount]).to_f
        note = params[:note]
        ordergroup = Ordergroup.find(trans[:ordergroup_id])
        if params[:set_balance]
          note += " (#{amount})"
          amount -= ordergroup.financial_transaction_class_balance(type.financial_transaction_class)
        end
        ordergroup.add_financial_transaction!(amount, note, @current_user, type, financial_link)
        foodcoop_amount -= amount
      end

      if params[:create_foodcoop_transaction]
        ft = FinancialTransaction.new({
                                        financial_transaction_type: type,
                                        user: @current_user,
                                        amount: foodcoop_amount,
                                        note: params[:note],
                                        financial_link: financial_link
                                      })
        ft.save!
      end

      financial_link.try(&:save!)
    end

    url = financial_link ? finance_link_url(financial_link.id) : finance_ordergroups_url
    redirect_to url, notice: I18n.t('finance.financial_transactions.controller.create_collection.notice')
  rescue StandardError => e
    flash.now[:alert] = e.message
    render action: :new_collection
  end

  protected

  def find_ordergroup
    if params[:ordergroup_id]
      @ordergroup = Ordergroup.include_transaction_class_sum.find(params[:ordergroup_id])
    else
      @foodcoop = true
    end
  end

  def authenticate_finance_or_self_service_and_own_ordergroup
    current_user.role_finance? || (
      FoodsoftConfig[:use_self_service] &&
      !@ordergroup.nil? &&
      @ordergroup.member?(current_user)
    )
  end
end
