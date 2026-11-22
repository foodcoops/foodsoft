# frozen_string_literal: true

module GroupExtensions
  extend ActiveSupport::Concern

  included do
    has_one :sepa_account_holder, dependent: :destroy
    accepts_nested_attributes_for :sepa_account_holder, allow_destroy: true

    def sepa_possible?
      sepa_account_holder&.all_fields_present? || false
    end
  end
end
