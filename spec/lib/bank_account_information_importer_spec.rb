require_relative '../spec_helper'

describe BankTransaction do
  let(:bank_account) { create :bank_account }

  it 'empty content' do
    content = <<-JSON
    JSON

    importer = BankAccountInformationImporter.new(bank_account)
    expect(importer.import!(content)).to be(nil)
  end

  it 'invalid JSON' do
    content = <<-JSON
      #invalid#
    JSON

    importer = BankAccountInformationImporter.new(bank_account)
    expect { importer.import!(content) }.to raise_error(JSON::ParserError)
  end

  it 'empty object' do
    content = <<-JSON
      {}
    JSON

    importer = BankAccountInformationImporter.new(bank_account)
    expect(importer.import!(content)).to eq(0)
  end

  it 'des sometet' do
    content = <<-JSON
      {
        "balances": [],
        "transactions": {}
      }
    JSON

    importer = BankAccountInformationImporter.new(bank_account)
    expect(importer.import!(content)).to eq(0)
  end

  it 'without actual content' do
    content = <<-JSON
      {
        "balances": [],
        "transactions": {
          "booked": []
        }
      }
    JSON

    importer = BankAccountInformationImporter.new(bank_account)
    expect(importer.import!(content)).to eq(0)
  end

  it 'use favorite balanceType' do
    content = <<-JSON
      {
        "balances": [
          {
            "balanceType": "authorised",
            "balanceAmount": {
              "currency": "EUR",
              "amount": "123.45"
            }
          },
          {
            "balanceType": "closingBooked",
            "balanceAmount": {
              "currency": "EUR",
              "amount": "234.56"
            }
          },
          {
            "balanceType": "##UNKNOWN##",
            "balanceAmount": {
              "currency": "EUR",
              "amount": "345.67"
            }
          },
          {
            "balanceType": "expected",
            "balanceAmount": {
              "currency": "EUR",
              "amount": "456.78"
            }
          }
        ]
      }
    JSON

    importer = BankAccountInformationImporter.new(bank_account)
    expect(importer.import!(content)).to eq(0)
    expect(bank_account.balance).to eq(234.56)
  end

  it 'use unknown balance if no other exists' do
    content = <<-JSON
      {
        "balances": [
          {
            "balanceType": "##UNKNOWN##",
            "balanceAmount": {
              "currency": "EUR",
              "amount": "123.45"
            }
          }
        ]
      }
    JSON

    importer = BankAccountInformationImporter.new(bank_account)
    expect(importer.import!(content)).to eq(0)
    expect(bank_account.balance).to eq(123.45)
  end

  it 'use transaction sum as balance' do
    content = <<-JSON
      {
        "transactions": {
          "booked": [
            {
              "transactionId": "1",
              "transactionAmount": {
                "currency": "EUR",
                "amount": "12.3"
              },
              "bookingDate": "2019-02-14",
              "valueDate": "2019-02-13",
              "debtorName": "Example User"
            },
            {
              "transactionId": "2",
              "transactionAmount": {
                "currency": "EUR",
                "amount": "-1.2"
              },
              "bookingDate": "2019-02-12",
              "valueDate": "2019-02-11",
              "debtorName": "Example Supplier"
            }
          ]
        }
      }
    JSON

    importer = BankAccountInformationImporter.new(bank_account)
    expect(importer.import!(content)).to eq(2)
    expect(bank_account.last_transaction_date).to eq('2019-02-14'.to_date)
    expect(bank_account.balance).to eq(11.1)
  end

  it 'can import debit entry' do
    content = <<-JSON
      {
        "transactions": {
          "booked": [
            {
              "transactionAmount": {
                "currency": "EUR",
                "amount": "-194.83"
              },
              "creditorAccount": {
                "iban": "DE72957284895783674747"
              },
              "creditorName": "Deutsche Bundesbahn",
              "creditorId": "DE76356347538353",
              "mandateId": "34564OB3633ZT3",
              "remittanceInformationUnstructured": "743574386368 Muenchen-Hamburg 27.03.2019",
              "bookingDate": "2019-02-13",
              "valueDate": "2019-02-13",
              "entryReference": "3648793450370305937",
              "transactionId": "3648793450370305937",
              "bankTransactionCode": "PMNT-RDDT-ESDD",
              "additionalInformation": "Lastschrift"
            }
          ]
        }
      }
    JSON

    importer = BankAccountInformationImporter.new(bank_account)
    expect(importer.import!(content)).to eq(1)

    bt = bank_account.bank_transactions.first
    expect(bt.amount).to eq(-194.83)
    expect(bt.date).to eq('2019-02-13'.to_date)
    expect(bt.text).to eq('Deutsche Bundesbahn')
    expect(bt.iban).to eq('DE72957284895783674747')
    expect(bt.reference).to eq("743574386368 Muenchen-Hamburg 27.03.2019")
    expect(bt.receipt).to eq('Lastschrift')
  end

  it 'can import US bank transfer' do
    content = <<-JSON
      {
        "transactions": {
          "booked": [
            {
              "transactionAmount": {
                "currency": "EUR",
                "amount": "-238.68"
              },
              "originalAmount": {
                "currency": "USD",
                "amount": "-270.46"
              },
              "currencyExchange": {
                "sourceCurrency": "EUR",
                "targetCurrency": "USD",
                "unitCurrency": "EUR",
                "quotationDate": "2019-02-13",
                "exchangeRate": "1.13315"
              },
              "creditorAccount": {
                "bban": "693757683985"
              },
              "creditorAgent": "FRTZUSWA435",
              "creditorName": "Hammersmith Inc.",
              "creditorAddress": "1326 Canwood Drive, CA 45562, US",
              "remittanceInformationUnstructured": "Martin Schöneicher, Inv# 123453423, Thx",
              "endToEndId": "Corvette Ersatzteile",
              "bookingDate": "2019-02-13",
              "valueDate": "2019-02-13",
              "entryReference": "8463794476737676345",
              "transactionId": "8463794476737676345",
              "bankTransactionCode": "PMNT-ICDT-XBCT",
              "additionalInformation": "Auslands-Überweisung"
            }
          ]
        }
      }
    JSON

    importer = BankAccountInformationImporter.new(bank_account)
    expect(importer.import!(content)).to eq(1)

    bt = bank_account.bank_transactions.first
    expect(bt.amount).to eq(-238.68)
    expect(bt.date).to eq('2019-02-13'.to_date)
    expect(bt.text).to eq('Hammersmith Inc.')
    expect(bt.iban).to be(nil)
    expect(bt.reference).to eq('Martin Schöneicher, Inv# 123453423, Thx')
    expect(bt.receipt).to eq('Auslands-Überweisung')
  end

  it 'can import bank fees' do
    content = <<-JSON
      {
        "transactions": {
          "booked": [
            {
              "transactionAmount": {
                "currency": "EUR",
                "amount": "-12.3"
              },
              "creditorName": "superbank AG",
              "remittanceInformationUnstructured": "Überweisung US, Wechselspesen u Provision",
              "bookingDate": "2019-02-14",
              "valueDate": "2019-02-13",
              "entryReference": "3346453823263457367",
              "transactionId": "3346453823263457367",
              "bankTransactionCode": "ACMT-MCOP-CHRG",
              "additionalInformation": "Spesen/Gebühren"
            }
          ]
        }
      }
    JSON

    importer = BankAccountInformationImporter.new(bank_account)
    expect(importer.import!(content)).to eq(1)

    bt = bank_account.bank_transactions.first
    expect(bt.amount).to eq(-12.3)
    expect(bt.date).to eq('2019-02-14'.to_date)
    expect(bt.text).to eq('superbank AG')
    expect(bt.iban).to be(nil)
    expect(bt.reference).to eq("Überweisung US, Wechselspesen u Provision")
    expect(bt.receipt).to eq('Spesen/Gebühren')
  end

  it 'can import credit entry' do
    content = <<-JSON
      {
        "transactions": {
          "booked": [
            {
              "transactionAmount": {
                "currency": "EUR",
                "amount": "136.47"
              },
              "debtorAccount": {
                "iban": "AT251657674147449499"
              },
              "debtorName": "Maria Reithuber",
              "remittanceInformationUnstructured": "Danke für's Auslegen",
              "endToEndId": "Auslage von Martin S.",
              "bookingDate": "2019-02-14",
              "valueDate": "2019-02-14",
              "entryReference": "4856465768967584736",
              "transactionId": "4856465768967584736",
              "bankTransactionCode": "PMNT-RCDT-ESCT",
              "additionalInformation": "Gutschrift"
            }
          ]
        }
      }
    JSON

    importer = BankAccountInformationImporter.new(bank_account)
    expect(importer.import!(content)).to eq(1)

    bt = bank_account.bank_transactions.first
    expect(bt.amount).to eq(136.47)
    expect(bt.date).to eq('2019-02-14'.to_date)
    expect(bt.text).to eq('Maria Reithuber')
    expect(bt.iban).to eq('AT251657674147449499')
    expect(bt.reference).to eq("Danke für's Auslegen")
    expect(bt.receipt).to eq('Gutschrift')
  end

  it 'use transaction sum as balance' do
    content = <<-JSON
      {
        "transactions": {
          "booked": [
            {
              "transactionId": "T1",
              "entryReference": "E1",
              "bookingDate": "2020-01-01",
              "valueDate": "2020-01-02",
              "transactionAmount": {
                "currency": "EUR",
                "amount": "11"
              },
              "creditorName": "CN1",
              "creditorAccount": {
                "iban": "CH9300762011623852957"
              },
              "debtorName": "DN1",
              "debtorAccount": {
                "iban": "DE72957284895783674747"
              },
              "additionalInformation": "AI1"
            },
            {
              "transactionId": "T2",
              "entryReference": "E2",
              "bookingDate": "2010-02-01",
              "valueDate": "2010-02-02",
              "transactionAmount": {
                "currency": "EUR",
                "amount": "-22"
              },
              "creditorName": "CN2",
              "creditorAccount": {
                "iban": "CH9300762011623852957"
              },
              "debtorName": "DN2",
              "debtorAccount": {
                "iban": "DE72957284895783674747"
              },
              "remittanceInformationUnstructured": "RI2"
            },
            {
              "transactionId": "T3",
              "bookingDate": "2000-03-01",
              "transactionAmount": {
                "currency": "EUR",
                "amount": "33"
              },
              "debtorName": "DN3"
            }
          ]
        }
      }
    JSON

    importer = BankAccountInformationImporter.new(bank_account)
    expect(importer.import!(content)).to eq(3)
    expect(bank_account.import_continuation_point).to eq('E1')
    expect(bank_account.last_transaction_date).to eq('2020-01-01'.to_date)
    expect(bank_account.balance).to eq(22)

    bt1 = bank_account.bank_transactions.find_by_external_id("T1")
    expect(bt1.amount).to eq(11)
    expect(bt1.date).to eq('2020-01-01'.to_date)
    expect(bt1.text).to eq('DN1')
    expect(bt1.iban).to eq('DE72957284895783674747')
    expect(bt1.reference).to be(nil)
    expect(bt1.receipt).to eq('AI1')

    bt2 = bank_account.bank_transactions.find_by_external_id("T2")
    expect(bt2.amount).to eq(-22)
    expect(bt2.date).to eq('2010-02-01'.to_date)
    expect(bt2.text).to eq('CN2')
    expect(bt2.iban).to eq('CH9300762011623852957')
    expect(bt2.reference).to eq('RI2')
    expect(bt2.receipt).to be(nil)

    bt3 = bank_account.bank_transactions.find_by_external_id("T3")
    expect(bt3.amount).to eq(33)
    expect(bt3.date).to eq('2000-03-01'.to_date)
    expect(bt3.text).to eq('DN3')
    expect(bt3.iban).to be(nil)
    expect(bt3.reference).to be(nil)
    expect(bt3.receipt).to be(nil)
  end
end
