module SuppliersHelper

  def associated_supplier_names(shared_supplier)
    "(#{shared_supplier.suppliers.map(&:name).join(', ')})"
  end

  def shared_sync_method_collection(shared_supplier)
    shared_supplier.shared_sync_methods.map do |m|
      [t("suppliers.shared_supplier_methods.#{m}"), m]
    end
  end
end
