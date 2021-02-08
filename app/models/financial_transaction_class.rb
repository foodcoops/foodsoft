class FinancialTransactionClass < ApplicationRecord
  has_many :financial_transaction_types, dependent: :destroy
  has_many :supplier_category, dependent: :restrict_with_exception
  has_many :financial_transactions, through: :financial_transaction_types
  has_many :ordergroups, -> { distinct }, through: :financial_transactions

  validates :name, presence: true
  validates_uniqueness_of :name

  after_save :update_balance_of_ordergroups

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

  private

  def update_balance_of_ordergroups
    ordergroups.each { |og| og.update_balance! }
  end
end
