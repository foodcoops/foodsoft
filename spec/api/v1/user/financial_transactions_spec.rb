require 'spec_helper'

# Most routes are tested in the swagger_spec, this tests endpoints that change data.
describe Api::V1::User::FinancialTransactionsController, type: :controller do
  include ApiOAuth
  let(:user) { create(:user, :ordergroup) }
  let(:api_scopes) { ['finance:user'] }

  let(:ftc1) { create :financial_transaction_class }
  let(:ftc2) { create :financial_transaction_class }
  let(:ftt1) { create :financial_transaction_type, financial_transaction_class: ftc1 }
  let(:ftt2) { create :financial_transaction_type, financial_transaction_class: ftc2 }
  let(:ftt3) { create :financial_transaction_type, financial_transaction_class: ftc2 }

  let(:amount) { rand(-100..100) }
  let(:note) { Faker::Lorem.sentence }

  let(:json_ft) { json_response['financial_transaction'] }

  shared_examples "financial_transactions endpoint success" do
    before { request }

    it "returns status 200" do
      expect(response).to have_http_status :ok
    end
  end

  shared_examples "financial_transactions create/update success" do
    include_examples "financial_transactions endpoint success"

    it "returns the financial_transaction" do
      expect(json_ft['id']).to be_present
      expect(json_ft['financial_transaction_type_id']).to eq ftt1.id
      expect(json_ft['financial_transaction_type_name']).to eq ftt1.name
      expect(json_ft['amount']).to eq amount
      expect(json_ft['note']).to eq note
      expect(json_ft['user_id']).to eq user.id
    end

    it "updates the financial_transaction" do
      resulting_ft = FinancialTransaction.where(id: json_ft['id']).first
      expect(resulting_ft).to be_present
      expect(resulting_ft.financial_transaction_type).to eq ftt1
      expect(resulting_ft.amount).to eq amount
      expect(resulting_ft.note).to eq note
      expect(resulting_ft.user).to eq user
    end
  end

  shared_examples "financial_transactions endpoint failure" do |status|
    it "returns status #{status}" do
      request
      expect(response.status).to eq status
    end

    it "does not change the ordergroup" do
      expect { request }.to_not change {
        user.ordergroup.attributes
      }
    end

    it "does not change the financial_transactions of ordergroup" do
      expect { request }.to_not change {
        user.ordergroup.financial_transactions.count
      }
    end
  end

  describe "POST :create" do
    let(:ft_params) { { amount: amount, financial_transaction_type_id: ftt1.id, note: note } }
    let(:request) { post :create, params: { financial_transaction: ft_params, foodcoop: 'f' } }

    context 'without using self service' do
      include_examples "financial_transactions endpoint failure", 403
    end

    context 'with using self service' do
      before { FoodsoftConfig[:use_self_service] = true }

      context "with no existing financial transaction" do
        include_examples "financial_transactions create/update success"
      end

      context "with existing financial transaction" do
        before { user.ordergroup.add_financial_transaction! 5000, 'for ordering', user, ftt3 }

        include_examples "financial_transactions create/update success"
      end

      context "with invalid financial transaction type" do
        let(:ft_params) { { amount: amount, financial_transaction_type_id: -1, note: note } }

        include_examples "financial_transactions endpoint failure", 404
      end

      context "without note" do
        let(:ft_params) { { amount: amount, financial_transaction_type_id: ftt1.id } }

        include_examples "financial_transactions endpoint failure", 422
      end

      context 'without enough balance' do
        before { FoodsoftConfig[:minimum_balance] = 1000 }

        include_examples "financial_transactions endpoint failure", 403
      end
    end
  end
end
