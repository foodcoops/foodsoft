class BankGateway < ApplicationRecord
  has_many :bank_accounts, dependent: :nullify
  belongs_to :unattended_user, class_name: 'User', optional: true

  scope :with_unattended_support, -> { where.not(unattended_user: nil) }

  validates :name, :url, presence: true
end
