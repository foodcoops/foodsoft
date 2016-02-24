class BankTransaction < ActiveRecord::Base

  belongs_to :bank_account
  belongs_to :money_transfer

  validates_presence_of :booking_date, :amount, :bank_account_id
  validates_numericality_of :amount

  # Replace numeric seperator with database format
  localize_input_of :amount

  def money_transfer_autocreate
    if money_transfer.nil?
      money_transfer = create_money_transfer()
      save
    end
    self.money_transfer
  end

  def related_ordergroup
    user = User.find_by(:iban => iban)
    user.nil? ? nil : user.ordergroup
  end

  def image_url
    'data:image/png;base64,' + Base64.encode64(self.image)
  end
end
