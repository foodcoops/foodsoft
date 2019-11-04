class Link < ApplicationRecord
  belongs_to :workgroup

  validates_presence_of :name, :url

  scope :ordered, -> { order(:name) }
end
