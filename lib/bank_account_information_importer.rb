class BankAccountInformationImporter
  def initialize(bank_account)
    @bank_account = bank_account
  end

  def import!(content)
    return nil if content.empty?

    data = JSON.parse content, symbolize_names: true

    return 0 if data.empty?

    booked = data.fetch(:transactions, {}).fetch(:booked, [])

    ret = 0
    booked.each do |t|
      amount = parse_account_information_amount t[:transactionAmount]
      entityName = amount < 0 ? t[:creditorName] : t[:debtorName]
      entityAccount = amount < 0 ? t[:creditorAccount] : t[:debtorAccount]

      @bank_account.bank_transactions.where(external_id: t[:transactionId]).first_or_create.update({
                                                                                                     date: t[:bookingDate],
                                                                                                     amount: amount,
                                                                                                     iban: entityAccount && entityAccount[:iban],
                                                                                                     reference: t[:remittanceInformationUnstructured],
                                                                                                     text: entityName,
                                                                                                     receipt: t[:additionalInformation],
                                                                                                   })
      ret += 1
    end

    balances = Hash[data[:balances] ? data[:balances].map { |b| [b[:balanceType], b[:balanceAmount]] } : []]
    balance = balances.values.first
    %w(closingBooked expected authorised openingBooked interimAvailable forwardAvailable nonInvoiced).each do |type|
      value = balances[type]
      if value then
        balance = value
        break
      end
    end

    @bank_account.balance = parse_account_information_amount(balance) || @bank_account.bank_transactions.sum(:amount)
    @bank_account.import_continuation_point = booked.first&.fetch(:entryReference, nil)
    @bank_account.last_import = Time.now
    @bank_account.save!

    ret
  end

  private

  def parse_account_information_amount(value)
    value && value[:amount].to_f
  end
end
