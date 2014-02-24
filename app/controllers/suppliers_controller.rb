# encoding: utf-8
class SuppliersController < ApplicationController
  before_filter :authenticate_suppliers, :except => [:index, :list]
  helper :deliveries

  def index
    @suppliers = Supplier.undeleted.order(:name)
    @deliveries = Delivery.recent
  end

  def show
    @supplier = Supplier.find(params[:id])
    @deliveries = @supplier.deliveries.recent
    @orders = @supplier.orders.recent
  end

  # new supplier
  # if shared_supplier_id is given, the new supplier will filled whith its attributes
  def new
    if params[:shared_supplier_id]
      shared_supplier =  SharedSupplier.find(params[:shared_supplier_id])
      @supplier = shared_supplier.suppliers.new(shared_supplier.autofill_attributes)
    else
      @supplier = Supplier.new
    end
  end

  def create    
    @supplier = Supplier.new(params[:supplier])
    if @supplier.save
      flash[:notice] = I18n.t('suppliers.create.notice')
      redirect_to suppliers_path
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
      flash[:notice] = I18n.t('suppliers.update.notice')
      redirect_to @supplier
    else
      render :action => 'edit'
    end
  end

  def destroy
    @supplier = Supplier.find(params[:id])
    @supplier.mark_as_deleted
    flash[:notice] = I18n.t('suppliers.destroy.notice')
    redirect_to suppliers_path
    rescue => e
      flash[:error] = I18n.t('errors.general_msg', :msg => e.message)
      redirect_to @supplier
  end  
  
  # gives a list with all available shared_suppliers
  def shared_suppliers
    @shared_suppliers = SharedSupplier.find(:all)
  end
  
end
