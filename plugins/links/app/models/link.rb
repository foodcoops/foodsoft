class Link < ApplicationRecord
  belongs_to :workgroup

  scope :ordered, -> { order(:name) }
end
