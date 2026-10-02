# frozen_string_literal: true

class OrderCollectiveDirectDebitXml
  attr_reader :xml_string

  def initialize(group_orders)
    batch_booking = group_orders.count > 1
    sdd = SEPA::DirectDebit.new(
      # Name of the initiating party  and creditor, in German: "Auftraggeber"
      # String, max. 70 char
      name: FoodsoftConfig[:name],

      # OPTIONAL: Business Identifier Code (SWIFT-Code) of the creditor
      # String, 8 or 11 char
      bic: FoodsoftConfig[:group_order_invoices][:bic],

      # International Bank Account Number of the creditor
      # String, max. 34 chars
      iban: FoodsoftConfig[:group_order_invoices][:iban], # remove spaces

      # Creditor Identifier, in German: Gläubiger-Identifikationsnummer
      # String, max. 35 chars
      creditor_identifier: FoodsoftConfig[:group_order_invoices][:creditor_identifier]
    )
    group_orders.each do |group_order|
      remittance_information = "#{group_order.ordergroup_invoice.invoice_number} #{group_order.multi_order.name}" if group_order.instance_of?(MultiGroupOrder)
      next if group_order.price == 0

      sdd.add_transaction(
        # Name of the debtor, in German: "Zahlungspflichtiger"
        # String, max. 70 char
        name: group_order.ordergroup.name,

        # Ende zu Ende Referenz
        reference: 'NOTPROVIDED',

        # OPTIONAL: Business Identifier Code (SWIFT-Code) of the debtor's account
        # String, 8 or 11 char
        bic: group_order.ordergroup.sepa_account_holder.bic.gsub(' ', ''),

        # International Bank Account Number of the debtor's account
        # String, max. 34 chars
        iban: group_order.ordergroup.sepa_account_holder.iban.gsub(' ', ''),

        # Amount
        # Number with two decimal digit
        amount: group_order.price,

        # OPTIONAL: Currency, EUR by default (ISO 4217 standard)
        # String, 3 char
        currency: 'EUR',

        # OPTIONAL: Instruction Identification, will not be submitted to the debtor
        # String, max. 35 char
        # instruction: '12345',

        # OPTIONAL: Unstructured remittance information, in German "Verwendungszweck"
        # String, max. 140 char
        remittance_information: remittance_information || "#{group_order.group_order_invoice.invoice_number} #{group_order.order.supplier.name}",

        # Mandate identifikation, in German "Mandatsreferenz"
        # String, max. 35 char
        mandate_id: group_order.ordergroup.sepa_account_holder.mandate_id,

        # Mandate Date of signature, in German "Datum, zu dem das Mandat unterschrieben wurde"
        # Date
        mandate_date_of_signature: group_order.ordergroup.sepa_account_holder.mandate_date_of_signature,

        # Local instrument, in German "Lastschriftart"
        # One of these strings:
        #   'CORE' ("Basis-Lastschrift")
        #   'COR1' ("Basis-Lastschrift mit verkürzter Vorlagefrist")
        #   'B2B' ("Firmen-Lastschrift")
        local_instrument: 'CORE',

        # Sequence type
        # One of these strings:
        #   'FRST' ("Erst-Lastschrift")
        #   'RCUR' ("Folge-Lastschrift")
        #   'OOFF' ("Einmalige Lastschrift")
        #   'FNAL' ("Letztmalige Lastschrift")
        sequence_type: group_order.group_order_invoice.sepa_sequence_type || 'RCUR',

        # OPTIONAL: Requested collection date, in German "Fälligkeitsdatum der Lastschrift"
        # Date
        requested_date: Time.zone.today + 2.days,

        # OPTIONAL: Enables or disables batch booking, in German "Sammelbuchung / Einzelbuchung"
        # True or False
        batch_booking: batch_booking
      )
      # Last: create XML string
    end
    @xml_string = sdd.to_xml # Use schema pain.008.001.02
  end
end
