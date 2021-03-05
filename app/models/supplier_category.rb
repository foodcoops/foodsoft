class SupplierCategory < ActiveRecord::Base
  belongs_to :financial_transaction_class
  belongs_to :bank_account, optional: true
  has_many :suppliers

  normalize_attributes :name, :description

  validates :name, presence: true, uniqueness: true, length: { minimum: 2 }

  before_destroy :check_for_associated_suppliers

  protected

  # Deny deleting the category when there are associated suppliers.
  def check_for_associated_suppliers
    raise I18n.t('activerecord.errors.has_many_left', collection: Supplier.model_name.human) if suppliers.undeleted.any?
  end
end
