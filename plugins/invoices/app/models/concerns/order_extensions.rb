# frozen_string_literal: true

module OrderExtensions
  extend ActiveSupport::Concern

  included do
    scope :non_multi_order, -> { where(multi_order_id: nil) }
  end
end
