require 'spec_helper'

RSpec.describe SepaAccountHolder do
  let(:group) { create(:group) }
  let(:user) { create(:user) }

  before do
    FoodsoftInvoices.enable_extensions!
  end

  describe '#all_fields_present?' do
    it 'returns true when all required fields are set' do
      sah = described_class.new(
        group: group,
        user: user,
        iban: 'DE89 3704 0044 0532 0130 00',
        bic: 'COBADEFFXXX',
        mandate_id: 'M-123',
        mandate_date_of_signature: Date.new(2024, 1, 1)
      )

      expect(sah.all_fields_present?).to be(true)
    end

    it 'returns false when some required fields are missing' do
      sah = described_class.new(group: group, user: user)
      expect(sah.all_fields_present?).to be(false)
    end
  end

  describe 'IBAN/BIC handling' do
    it 'strips whitespace from IBAN and BIC before validation' do
      sah = described_class.new(
        group: group,
        user: user,
        iban: ' DE89 3704 0044 0532 0130 00 ',
        bic: " COBA DE FF XXX \t"
      )

      sah.valid? # triggers before_validation

      expect(sah.iban).to eq('DE89370400440532013000')
      expect(sah.bic).to eq('COBADEFFXXX')
    end

    it 'is invalid with an invalid IBAN when present' do
      sah = described_class.new(
        group: group,
        user: user,
        iban: 'INVALIDIBAN',
        bic: 'COBADEFFXXX'
      )

      expect(sah).not_to be_valid
      expect(sah.errors[:iban]).not_to be_empty
    end

    it 'is invalid with an invalid BIC when present' do
      sah = described_class.new(
        group: group,
        user: user,
        iban: 'DE89370400440532013000',
        bic: 'INVALIDBIC'
      )

      expect(sah).not_to be_valid
      expect(sah.errors[:bic]).not_to be_empty
    end
  end
end
