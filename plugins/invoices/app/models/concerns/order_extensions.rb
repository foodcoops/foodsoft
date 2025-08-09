# frozen_string_literal: true

module OrderExtensions
  extend ActiveSupport::Concern

  included do
    belongs_to :multi_order, optional: true, inverse_of: :orders
    scope :non_multi_order, -> { where(multi_order_id: nil) }
  end
end
