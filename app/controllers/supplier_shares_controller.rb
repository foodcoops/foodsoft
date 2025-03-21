class SupplierSharesController < ApplicationController
  before_action :authenticate_suppliers

  def create
    @supplier = Supplier.find(params[:supplier_id])
    @supplier.update_attribute(:external_uuid, SecureRandom.uuid)

    render 'update'
  end

  def destroy
    @supplier = Supplier.find(params[:supplier_id])
    @supplier.update_attribute(:external_uuid, nil)

    render 'update'
  end
end
