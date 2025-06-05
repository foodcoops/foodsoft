require_relative '../spec_helper'
require 'rake'

describe Rake::Task do
  describe 'foodsoft:remote_sync_suppliers' do
    before do
      Foodsoft::Application.load_tasks unless described_class.task_defined?('foodsoft:remote_sync_suppliers')
      # Reset the Rake task before each test
      described_class['foodsoft:remote_sync_suppliers'].reenable
    end

    it 'syncs suppliers with remote_auto_sync flag' do
      supplier1 = create(:supplier, remote_auto_sync: true)
      supplier2 = create(:supplier, remote_auto_sync: true)
      supplier3 = create(:supplier, remote_auto_sync: false)

      service1 = instance_double(SupplierSyncService)
      service2 = instance_double(SupplierSyncService)
      allow(service1).to receive(:sync).and_return(true)
      allow(service2).to receive(:sync).and_return(true)
      allow(SupplierSyncService).to receive(:new).with(supplier1).and_return(service1)
      allow(SupplierSyncService).to receive(:new).with(supplier2).and_return(service2)
      allow(SupplierSyncService).to receive(:new).with(supplier3).and_return(nil)

      described_class['foodsoft:remote_sync_suppliers'].invoke

      expect(SupplierSyncService).to have_received(:new).with(supplier1)
      expect(SupplierSyncService).to have_received(:new).with(supplier2)
      expect(SupplierSyncService).not_to have_received(:new).with(supplier3)
      expect(service1).to have_received(:sync)
      expect(service2).to have_received(:sync)
    end

    it 'handles sync failures gracefully' do
      supplier = create(:supplier, remote_auto_sync: true)

      service = instance_double(SupplierSyncService)
      allow(service).to receive(:sync).and_return(false)
      allow(SupplierSyncService).to receive(:new).and_return(service)

      described_class['foodsoft:remote_sync_suppliers'].invoke

      expect(SupplierSyncService).to have_received(:new).with(supplier)
      expect(service).to have_received(:sync)
    end
  end
end
