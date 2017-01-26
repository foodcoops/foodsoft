class BankAccount < ApplicationRecord

  has_many :bank_transactions, dependent: :destroy

  normalize_attributes :name, :iban, :description

  validates :name, :presence => true, :uniqueness => true, :length => { :minimum => 2 }
  validates :iban, :presence => true, :uniqueness => true
  validates_format_of :iban, :with => /\A[A-Z]{2}[0-9]{2}[0-9A-Z]{,30}\z/
  validates_numericality_of :balance, :message => I18n.t('bank_account.model.invalid_balance')

  # @return [Function] Method wich can be called to import transaction from a bank or nil if unsupported
  def find_import_method
  end

  def assign_unlinked_transactions
    count = 0
    bank_transactions.without_financial_link.includes(:supplier, :user).each do |t|
      if t.assign_to_ordergroup || t.assign_to_invoice
        count += 1
      end
    end
    count
  end
end
