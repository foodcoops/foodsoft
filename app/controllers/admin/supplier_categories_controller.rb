class Admin::SupplierCategoriesController < Admin::BaseController
  inherit_resources

  def new
    @supplier_category = SupplierCategory.new(params[:supplier_category])
    render layout: false
  end

  def create
    @supplier_category = SupplierCategory.new(params[:supplier_category])
    if @supplier_category.valid? && @supplier_category.save
      redirect_to update_supplier_categories_admin_finances_url, status: :see_other
    else
      render action: 'new', layout: false
    end
  end

  def edit
    @supplier_category = SupplierCategory.find(params[:id])
    render action: 'new', layout: false
  end

  def update
    @supplier_category = SupplierCategory.find(params[:id])

    if @supplier_category.update(params[:supplier_category])
      redirect_to update_supplier_categories_admin_finances_url, status: :see_other
    else
      render action: 'new', layout: false
    end
  end

  def destroy
    @supplier_category = SupplierCategory.find(params[:id])
    @supplier_category.destroy
    redirect_to update_supplier_categories_admin_finances_url, status: :see_other
  rescue StandardError => e
    flash.now[:alert] = e.message
    render template: 'shared/alert'
  end
end
