require 'roo'

class BankAccount < ActiveRecord::Base

  has_many :bank_transactions, dependent: :destroy

  normalize_attributes :name, :iban, :description

  validates :name, :presence => true, :uniqueness => true, :length => { :minimum => 2 }
  validates :iban, :presence => true, :uniqueness => true
  validates_format_of :iban, :with => /\A[A-Z]{2}[0-9]{2}[0-9A-Z]{,30}\z/
  validates_numericality_of :balance, :message => I18n.t('bank_account.model.invalid_balance')

  def import_from_file(file, options = {})
    SpreadsheetFile.parse file, options do |row|
      bank_transactions.where(:external_id => row[0]).first_or_create.update(
                              :date => row[1],
                              :amount => row[2],
                              :iban => row[3],
                              :text => row[4],
                              :reference => row[5],
                              :receipt => row[6],
                              :image => row[7].nil? ? nil : Base64.decode64(row[7]))
      count += 1
    end
    count
  end
end
