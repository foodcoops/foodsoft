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

  def find_import_method
    # TODO: Move lookup for import function into plugin
    return method(:import_from_easybank) if /^AT\d{2}14200\d{11}$/.match(iban)
    return method(:import_from_sparkasse) if /^AT\d{2}20111\d{11}$/.match(iban)
    return method(:import_from_holvi) if /^FI\d{2}799779\d{7}[0-9A-Z]$/.match(iban)
  end

  def assign_unchecked_transactions
    count = 0
    bank_transactions.without_financial_link.includes(:supplier, :user).each do |t|
      if t.assign_to_ordergroup || t.assign_to_invoice
        count += 1
      end
    end
    count
  end

  private

  def import_from_easybank(bank_account)
    easybank_config = FoodsoftConfig[:easybank]
    raise "easybank configuration missing" if not easybank_config

    dn = easybank_config[:dn]
    pin = easybank_config[:pin]
    account = bank_account.iban[-11,11]

    count = 0
    continuation_point = nil

    Easybank.login(dn, pin) do |eb|
      bank_account.balance = eb.balance(account)
      eb.transactions(account, bank_account.import_continuation_point || '0').each do |t|
        bank_account.bank_transactions.where(:external_id => t[:id]).first_or_create.update(
          :date => t[:booking_date],
          :amount => t[:amount],
          :iban => t[:iban],
          :reference => t[:reference] ? t[:reference] : t[:reference2],
          :text => t[:raw],
          :receipt => t[:receipt],
          :image => t[:image])

        count += 1
        continuation_point = t[:id]
      end
    end

    bank_account.last_import = Time.now
    bank_account.import_continuation_point = continuation_point unless continuation_point.nil?
    bank_account.save!

    return count
  end

  def import_from_holvi(bank_account)
    holvi_config = FoodsoftConfig[:holvi]
    raise "holvi configuration missing" if not holvi_config

    username = holvi_config[:username]
    password = holvi_config[:password]
    iban = bank_account.iban

    count = 0
    continuation_point = nil

    Holvi.login(username, password) do |h|
      bank_account.balance = h.balance(iban)
      continuation_point = h.transactions(iban, bank_account.import_continuation_point || '') do |t|
        bank_account.bank_transactions.where(:external_id => t[:uuid]).first_or_create.update(
          :date => t[:timestamp],
          :amount => t[:amount],
          :iban => t[:iban],
          :reference => t[:message],
          :text => t[:name])

        count += 1
      end
    end

    bank_account.last_import = Time.now
    bank_account.import_continuation_point = continuation_point unless continuation_point.nil?
    bank_account.save!

    return count
  end

  def import_from_sparkasse(bank_account)
    sparkasse_config = FoodsoftConfig[:sparkasse]
    raise "sparkasse configuration missing" if not sparkasse_config

    username = sparkasse_config[:username]
    password = sparkasse_config[:password]
    iban = bank_account.iban

    count = 0
    continuation_point = nil

    Sparkasse.login(username, password) do |h|
      bank_account.balance = h.balance(iban)
      continuation_point = h.transactions(iban, bank_account.import_continuation_point || '') do |t|
        bank_account.bank_transactions.where(:external_id => t[:id]).first_or_create.update(
          :date => t[:date],
          :amount => t[:amount],
          :iban => t[:iban],
          :reference => t[:text],
          :text => t[:name])

        count += 1
      end
    end

    bank_account.last_import = Time.now
    bank_account.import_continuation_point = continuation_point unless continuation_point.nil?
    bank_account.save!

    return count
  end
end
