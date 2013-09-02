module SuppliersHelper

  def associated_supplier_names(shared_supplier)
    "(#{shared_supplier.suppliers.map(&:name).join(', ')})"
  end
end