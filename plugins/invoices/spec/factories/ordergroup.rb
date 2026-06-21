FactoryBot.define do
  factory :ordergroup_with_sepa, parent: :ordergroup do
    after(:create) do |group|
      create(:sepa_account_holder, group: group, user: create(:user))
    end
  end
end
