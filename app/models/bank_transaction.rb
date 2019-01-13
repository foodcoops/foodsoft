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
end
