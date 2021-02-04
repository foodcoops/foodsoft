class FinancialTransactionType < ApplicationRecord
  belongs_to :financial_transaction_class
  belongs_to :bank_account, optional: true
  has_many :financial_transactions, dependent: :restrict_with_exception

  validates :name, presence: true
  validates_uniqueness_of :name
  validates_uniqueness_of :name_short, allow_blank: true, allow_nil: true
  validates_format_of :name_short, :with => /\A[A-Za-z]*\z/
  validates :financial_transaction_class, presence: true

  before_destroy :restrict_deleting_last_financial_transaction_type

  scope :with_name_short, -> { where.not(name_short: [nil, '']) }

  def self.default
    first
  end

  def self.has_multiple_types
    self.count > 1
  end

  protected

  # check if this is the last financial transaction type and deny
  def restrict_deleting_last_financial_transaction_type
    raise I18n.t('model.financial_transaction_type.no_delete_last') if FinancialTransactionType.count == 1
  end
end
