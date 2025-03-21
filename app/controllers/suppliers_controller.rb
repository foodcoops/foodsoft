require 'ostruct'

class SuppliersController < ApplicationController
  before_action :authenticate_suppliers, except: %i[index list]
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
  def new
    @supplier = Supplier.new
  end

  def edit
    @supplier = Supplier.find(params[:id])
  end

  def create
    @supplier = Supplier.new(supplier_params)
    @supplier.supplier_category ||= SupplierCategory.first
    @supplier.unit_migration_completed = Time.now

    if @supplier.save
      flash[:notice] = I18n.t('suppliers.create.notice')
      redirect_to suppliers_path
    else
      render action: 'new'
    end
  end

  def update
    @supplier = Supplier.find(params[:id])
    if @supplier.update(supplier_params)
      flash[:notice] = I18n.t('suppliers.update.notice')
      redirect_to @supplier
    else
      render action: 'edit'
    end
  end

  def destroy
    @supplier = Supplier.find(params[:id])
    @supplier.mark_as_deleted
    flash[:notice] = I18n.t('suppliers.destroy.notice')
    redirect_to suppliers_path
  rescue StandardError => e
    flash[:error] = I18n.t('errors.general_msg', msg: e.message)
    redirect_to @supplier
  end

  def remote_articles
    @supplier = Supplier.find(remote_articles_params.fetch(:supplier_id))
    search_params = {}
    search_params[:name] = params.fetch(:name).split if params.include?(:name)
    search_params[:origin] = params.fetch(:origin) if params.include?(:origin)
    search_params[:page] = params.fetch(:page, 1)
    search_params[:per_page] = @per_page
    data = @supplier.read_from_remote(search_params)
    @articles = data[:articles]
    @pagination = OpenStruct.new(data[:pagination])
  end

  private

  def remote_articles_params
    params.permit(:supplier_id, :name, :origin)
  end

  def supplier_params
    params
      .require(:supplier)
      .permit(:name, :address, :phone, :phone2, :fax, :email, :url, :contact_person, :customer_number,
              :iban, :custom_fields, :delivery_days, :order_howto, :note, :supplier_category_id,
              :min_order_quantity, :shared_sync_method, :supplier_remote_source)
  end
end
