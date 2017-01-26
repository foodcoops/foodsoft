class BankTransaction < ApplicationRecord

  # @!attribute external_id
  #   @return [String] Unique Identifier of the transaction within the bank account.
  # @!attribute date
  #   @return [Date] Date of the transaction.
  # @!attribute amount
  #   @return [Number] Amount credited.
  # @!attribute iban
  #   @return [String] Internation Bank Account Number of the sending/receiving account.
  # @!attribute reference
  #   @return [String] 140 character long reference field as defined by SEPA.
  # @!attribute text
  #   @return [String] Short description of the transaction.
  # @!attribute receipt
  #   @return [String] Optional additional more detailed description of the transaction.
  # @!attribute image
  #   @return [Binary] Optional PNG image for e.g. scan of paper receipt.

  belongs_to :bank_account
  belongs_to :financial_link
  belongs_to :supplier, foreign_key: 'iban', primary_key: 'iban'
  belongs_to :user, foreign_key: 'iban', primary_key: 'iban'

  validates_presence_of :date, :amount, :bank_account_id
  validates_numericality_of :amount

  scope :without_financial_link, -> { where(financial_link: nil) }

  # Replace numeric seperator with database format
  localize_input_of :amount

  def image_url
    'data:image/png;base64,' + Base64.encode64(self.image)
  end

  def assign_to_invoice
    return false unless supplier

    content = text
    content += "\n" + reference if reference.present?
    invoices = supplier.invoices.unpaid.select {|i| content.include? i.number}
    invoices_sum = invoices.map(&:amount).sum
    return false if amount != -invoices_sum

    transaction do
      link = FinancialLink.new
      invoices.each {|i| i.update_attributes! financial_link: link, paid_on: date }
      update_attribute :financial_link, link
    end

    return true
  end

  def assign_to_ordergroup
    m = BankTransactionReference.parse(reference)
    return unless m

    return false if m[:parts].values.sum != amount
    group = Ordergroup.find_by_id(m[:group])
    return false unless group
    usr = m[:user] ? User.find_by_id(m[:user]) : group.users.first
    return false unless usr

    transaction do
      note = "ID=#{id} (#{amount})"
      link = FinancialLink.new

      m[:parts].each do |short, value|
        ftt = FinancialTransactionType.find_by_name_short(short)
        return false unless ftt
        group.add_financial_transaction! value, note, usr, ftt, link if value > 0
      end

      update_attribute :financial_link, link
    end

    return true
  end
end
