require_relative '../spec_helper'

describe SupplierSharesController do
  let(:user) { create(:user, groups: [create(:workgroup, role_suppliers: true)]) }
  let(:supplier) { create(:supplier) }

  before do
    login user
  end

  it 'share supplier' do
    post_with_defaults :create, params: { supplier_id: supplier.id }, xhr: true
    expect(response).to have_http_status :ok
    expect(supplier.reload.external_uuid).not_to be_nil
  end

  it 'unshare supplier' do
    supplier.update_attribute(:external_uuid, 'something')

    delete_with_defaults :destroy, params: { supplier_id: supplier.id }, xhr: true
    expect(response).to have_http_status :ok
    expect(supplier.reload.external_uuid).to be_nil
  end
end
