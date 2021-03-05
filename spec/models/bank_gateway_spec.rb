require_relative '../spec_helper'

describe BankGateway do
  describe 'can_reconfigure' do
    let!(:admin) { create :admin }
    let!(:unattended_user) { create :user }
    let!(:other_user) { create :user }
    let!(:bank_gateway) { create :bank_gateway, unattended_user: unattended_user }

    it 'allows admin' do
      expect(bank_gateway).to be_can_reconfigure(admin)
    end

    it 'allows unattended_user' do
      expect(bank_gateway).to be_can_reconfigure(unattended_user)
    end

    it 'denys other_user' do
      expect(bank_gateway).not_to be_can_reconfigure(other_user)
    end
  end
end
