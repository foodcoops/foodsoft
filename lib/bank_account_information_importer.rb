class BankAccountInformationImporter
  def initialize(bank_account)
    @bank_account = bank_account
  end

  def import!(content)
    return nil if content.empty?

    import_data! JSON.parse(content, symbolize_names: true)
  end

  def import_data!(data)
    return 0 if data.empty?

    booked = data.fetch(:transactions, {}).fetch(:booked, [])

    ret = 0
    booked.each do |t|
      amount = parse_account_information_amount t[:transactionAmount]
      entityName = amount < 0 ? t[:creditorName] : t[:debtorName]
      entityAccount = amount < 0 ? t[:creditorAccount] : t[:debtorAccount]
      reference = [t[:endToEndId], t[:remittanceInformationUnstructured]].join("\n").strip

      @bank_account.bank_transactions.where(external_id: t[:transactionId]).first_or_create.update({
                                                                                                     date: t[:bookingDate],
                                                                                                     amount: amount,
                                                                                                     iban: entityAccount && entityAccount[:iban],
                                                                                                     reference: reference,
                                                                                                     text: entityName,
                                                                                                     receipt: t[:additionalInformation]
                                                                                                   })
      ret += 1
    end

    balances = (data[:balances] ? data[:balances].map { |b| [b[:balanceType], b[:balanceAmount]] } : []).to_h
    balance = balances.values.first
    %w(closingBooked expected authorised openingBooked interimAvailable forwardAvailable nonInvoiced).each do |type|
      value = balances[type]
      if value
        balance = value
        break
      end
    end

    @bank_account.balance = parse_account_information_amount(balance) || @bank_account.bank_transactions.sum(:amount)
    @bank_account.import_continuation_point = booked.first&.fetch(:entryReference, nil) unless booked.empty?
    @bank_account.last_import = Time.now
    @bank_account.save!

    ret
  end

  private

  def parse_account_information_amount(value)
    value && value[:amount].to_f
  end
end
