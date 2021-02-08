class FinancialTransactionTypeSerializer < ActiveModel::Serializer
  attributes :id, :name, :name_short
  attributes :bank_account_id, :bank_account_name, :bank_account_iban
  attributes :financial_transaction_class_id, :financial_transaction_class_name

  def financial_transaction_class_name
    object.financial_transaction_class.name
  end

  def bank_account_name
    object.bank_account.try(:name)
  end

  def bank_account_iban
    object.bank_account.try(:iban)
  end
end
