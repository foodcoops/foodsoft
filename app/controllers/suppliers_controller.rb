class SuppliersController < ApplicationController
  before_filter :authenticate_suppliers, :except => [:index, :list]

  verify :method => :post, :only => [ :destroy, :create, :update ], :redirect_to => { :action => :list }

  # messages
  MSG_SUPPLIER_DESTOYED = "Lieferant wurde gelöscht"
  MSG_SUPPLIER_UPDATED = 'Lieferant wurde aktualisiert'
  MSG_SUPPLIER_CREATED = "Lieferant wurde erstellt"
  
  def index
    list
    render :action => 'list'
  end

 def list
    @supplier_column_names = ["Name", "Telefon", "Email", "Kundennummer"]
    @supplier_columns = ["name", "phone", "email", "customer_number"]
    @suppliers = Supplier.find :all
  end

  def show
    @supplier = Supplier.find(params[:id])
    @supplier_column_names = ["Name", "Telefon", "Telefon2", "FAX", "Email", "URL", "Kontakt", "Kundennummer", "Liefertage", "BestellHowTo", "Notiz", "Mindestbestellmenge"]
    @supplier_columns = ["name", "phone", "phone2", "fax", "email", "url", "contact_person", "customer_number", "delivery_days", "order_howto", "note", "min_order_quantity"]
  end

  # new supplier
  # if shared_supplier_id is given, the new supplier will filled whith its attributes
  def new
    if params[:shared_supplier_id]
      shared_supplier =  SharedSupplier.find(params[:shared_supplier_id])
      @supplier = shared_supplier.build_supplier(shared_supplier.attributes)
    else
      @supplier = Supplier.new
    end
  end

  def create    
    @supplier = Supplier.new(params[:supplier])
    if @supplier.save
      flash[:notice] = MSG_SUPPLIER_CREATED
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end 
  end

  def edit    
    @supplier = Supplier.find(params[:id])
  end
  
  def update
    @supplier = Supplier.find(params[:id])
    if @supplier.update_attributes(params[:supplier])
      flash[:notice] = MSG_SUPPLIER_UPDATED
      redirect_to :action => 'show', :id => @supplier
    else
      render :action => 'edit'
    end
  end

  def destroy
    Supplier.find(params[:id]).destroy
    flash[:notice] = MSG_SUPPLIER_DESTOYED
    redirect_to :action => 'list'
    rescue => e
      flash[:error] = _("An error has occurred: ") + e.message
      redirect_to :action => 'show', :id => params[:id]
  end  
  
  # gives a list with all available shared_suppliers
  def shared_suppliers
    @shared_suppliers = SharedSupplier.find(:all)
  end
  
end
