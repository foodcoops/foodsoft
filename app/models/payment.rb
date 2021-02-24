# encoding: utf-8
# All kinds of payments that a FC needs to keep track of
class Payment < ApplicationRecord
  #include FindEachWithOrder
  include MarkAsDeletedWithName

  has_and_belongs_to_many :groups

  validates :name, :presence => true, :length => {:in => 1..25}
  validate :uniqueness_of_name

  attr_reader :group_tokens

  scope :undeleted, -> { where(deleted_at: nil) }

  def group_tokens=(ids)
    # Make sure only references to Ordergroups are allowed. This also has the
    # nice side effect, that ordergroups can only be added once
    self.group_ids = Ordergroup.where(:id => ids.split(",")).pluck(:id)
  end

  def deleted?
    deleted_at.present?
  end

  # Make sure, the name is uniqe and add a useful message if there already exists a deleted payment
  def uniqueness_of_name
    payment = Payment.where(name: name)
    payment = payment.where.not(id: self.id) unless new_record?
    if payment.exists?
      message = payment.first.deleted? ? :taken_with_deleted : :taken
      errors.add :name, message
    end
  end
end
