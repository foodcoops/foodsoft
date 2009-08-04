class Finance::TransactionsController < ApplicationController
  before_filter :authenticate_finance
  
  def index
    if (params[:per_page] && params[:per_page].to_i > 0 && params[:per_page].to_i <= 100)
      @per_page = params[:per_page].to_i
    else
      @per_page = 20
    end
    if params["sort"]
      sort = case params["sort"]
               when "name" then "name"
               when "account_balance" then "account_balance"
               when "name_reverse" then "name DESC"
               when "account_balance_reverse" then "account_balance DESC"
            end
    else
      sort = "name"
    end

    conditions = "name LIKE '%#{params[:query]}%'" unless params[:query].nil?

    @total = Ordergroup.without_deleted.count(:conditions => conditions)
    @groups = Ordergroup.without_deleted.paginate :conditions => conditions,
      :page => params[:page], :per_page => @per_page, :order => sort

    respond_to do |format|
      format.html
      format.js { render :partial => "ordergroups" }
    end
  end

  def list
    @group = Ordergroup.find(params[:id])

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

    conditions = ["note LIKE ?", "%#{params[:query]}%"] unless params[:query].nil?

    @total = @group.financial_transactions.count(:conditions => conditions)
    @financial_transactions = @group.financial_transactions.paginate(
      :page => params[:page],
      :per_page => 10,
      :conditions => conditions,
      :order => sort)

    respond_to do |format|
      format.html
      format.js { render :partial => "list" }
    end
  end

  def new
    @group = Ordergroup.find(params[:id])
    @financial_transaction = @group.financial_transactions.build
  end

  def create
    @group = Ordergroup.find(params[:financial_transaction][:ordergroup_id])
    amount = params[:financial_transaction][:amount]
    note = params[:financial_transaction][:note]
    begin
      @group.add_financial_transaction(amount, note, @current_user)
      flash[:notice] = 'Transaktion erfolgreich angelegt.'
      redirect_to :action => 'list', :id => @group
    rescue => e
      @financial_transaction = FinancialTransaction.new(params[:financial_transaction])
      flash.now[:error] = 'Transaktion konnte nicht angelegt werden!' + ' (' + e.message + ')'
      render :action => 'new'
    end
  end

  def new_collection
  end

  def create_collection
    note = params[:note]
    raise "Notiz wird benötigt!" if note.blank?
    params[:financial_transactions].each do |trans|
      # ignore empty amount fields ...
      unless trans[:amount].blank?
        Ordergroup.find(trans[:ordergroup_id]).add_financial_transaction trans[:amount], note, @current_user
      end
    end
    flash[:notice] = "Alle Transaktionen wurden gespeichert."
    redirect_to :action => 'index'
  rescue => error
    flash[:error] = "Ein Fehler ist aufgetreten: " + error.to_s
    redirect_to :action => 'new_collection'
  end

end
