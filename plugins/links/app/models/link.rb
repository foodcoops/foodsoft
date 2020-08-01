class Link < ApplicationRecord
  belongs_to :workgroup, optional: true

  validates_presence_of :name, :url

  scope :ordered, -> { order(:name) }
end
