class Finance::InvoicesController < ApplicationController

  def index
    @invoices = Invoice.includes(:supplier, :delivery, :order).order('date DESC').paginate(page: params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @invoices }
    end
  end

  def show
    @invoice = Invoice.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @invoice }
    end
  end

  def new
    @invoice = Invoice.new :supplier_id => params[:supplier_id],
      :delivery_id => params[:delivery_id], :order_id => params[:order_id]

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @invoice }
    end
  end

  def edit
    @invoice = Invoice.find(params[:id])
  end

  # POST /invoices
  # POST /invoices.xml
  def create
    @invoice = Invoice.new(params[:invoice])

    if @invoice.save
      flash[:notice] = "Rechnung wurde erstellt."
      if @invoice.order
        # Redirect to balancing page
        redirect_to :controller => 'balancing', :action => 'new', :id => @invoice.order
      else
        redirect_to [:finance, @invoice]
      end
    else
      render :action => "new"
    end
  end

  # PUT /invoices/1
  # PUT /invoices/1.xml
  def update
    @invoice = Invoice.find(params[:id])

    respond_to do |format|
      if @invoice.update_attributes(params[:invoice])
        flash[:notice] = 'Invoice was successfully updated.'
        format.html { redirect_to([:finance, @invoice]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @invoice.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /invoices/1
  # DELETE /invoices/1.xml
  def destroy
    @invoice = Invoice.find(params[:id])
    @invoice.destroy

    respond_to do |format|
      format.html { redirect_to(finance_invoices_path) }
      format.xml  { head :ok }
    end
  end
end
