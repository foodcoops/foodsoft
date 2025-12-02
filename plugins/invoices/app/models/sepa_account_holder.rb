class SepaAccountHolder < ApplicationRecord
  require 'sepa_king'

  belongs_to :group
  belongs_to :user

  validates_with SEPA::IBANValidator, field_name: :iban, if: -> { iban.present? }
  validates_with SEPA::BICValidator, field_name: :bic, if: -> { bic.present? }

  before_validation :strip_whitespace_from_bic_and_iban

  def all_fields_present?
    iban.present? && bic.present? && mandate_id.present? && user_id.present? && mandate_date_of_signature.present? && group_id.present?
  end

  private

  def strip_whitespace_from_bic_and_iban
    self.iban = iban&.gsub(/\s+/, '')
    self.bic = bic&.gsub(/\s+/, '')
  end
end
