class DeliveriesController < ApplicationController

  before_filter :find_supplier

  def index
    @deliveries = @supplier.deliveries.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @deliveries }
    end
  end

  def show
    @delivery = Delivery.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @delivery }
    end
  end

  def new
    @delivery = @supplier.deliveries.build
    3.times { @delivery.stock_changes.build }
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @delivery }
    end
  end

  def edit
    @delivery = Delivery.find(params[:id])
  end

  def create
    @delivery = Delivery.new(params[:delivery])

    respond_to do |format|
      if @delivery.save
        flash[:notice] = 'Delivery was successfully created.'
        format.html { redirect_to([@supplier,@delivery]) }
        format.xml  { render :xml => @delivery, :status => :created, :location => @delivery }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @delivery.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /deliveries/1
  # PUT /deliveries/1.xml
  def update
    @delivery = Delivery.find(params[:id])

    respond_to do |format|
      if @delivery.update_attributes(params[:delivery])
        flash[:notice] = 'Delivery was successfully updated.'
        format.html { redirect_to([@supplier,@delivery]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @delivery.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @delivery = Delivery.find(params[:id])
    @delivery.destroy

    respond_to do |format|
      format.html { redirect_to(supplier_deliveries_url(@supplier)) }
      format.xml  { head :ok }
    end
  end

  def drop_stock_change
    stock_change = StockChange.find(params[:stock_change_id])
    stock_change.destroy

    render :update do |page|
      page.visual_effect(:DropOut, "stock_change_#{stock_change.id}")
    end
  end
  
  protected

  def find_supplier
    @supplier = Supplier.find(params[:supplier_id]) if params[:supplier_id]
  end
end
