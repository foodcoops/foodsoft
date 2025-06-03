require_relative '../spec_helper'

describe SupplierSyncService do
  describe '#sync' do
    let(:supplier) { create(:supplier) }

    it 'returns true when no changes are needed' do
      allow(supplier).to receive(:sync_from_remote).and_return([[], [], []])
      expect(described_class.new(supplier).sync).to be true
    end

    it 'returns true when changes are applied' do
      article = create(:article, supplier: supplier)
      allow(supplier).to receive(:sync_from_remote).and_return([[[article, { name: 'New Name' }]], [], []])
      expect(described_class.new(supplier).sync).to be true
    end

    it 'handles exceptions gracefully' do
      allow(supplier).to receive(:sync_from_remote).and_raise(StandardError.new('Test error'))
      expect(described_class.new(supplier).sync).to be false
    end
  end
end
