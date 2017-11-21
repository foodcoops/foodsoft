class FinancialTransactionClass < ActiveRecord::Base
  has_many :financial_transaction_types, dependent: :destroy

  validates :name, presence: true
  validates_uniqueness_of :name

  scope :sorted, -> { order(name: :asc) }

  def self.has_multiple_classes
    FinancialTransactionClass.count > 1
  end

  def display
    if FinancialTransactionClass.has_multiple_classes
      name
    else
      I18n.t('activerecord.attributes.financial_transaction.amount')
    end
  end
end
