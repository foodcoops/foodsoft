# Groups organize the User.
# A Member gets the roles from the Group
class Group < ApplicationRecord
  include FindEachWithOrder
  include MarkAsDeletedWithName

  has_many :memberships, dependent: :destroy
  has_many :users, -> { where(deleted_at: nil) }, through: :memberships

  validates :name, :presence => true, :length => { :in => 1..25 }
  validates_uniqueness_of :name

  attr_reader :user_tokens

  scope :undeleted, -> { where(deleted_at: nil) }

  # Returns true if the given user if is an member of this group.
  def member?(user)
    memberships.find_by_user_id(user.id)
  end

  # Returns all NONmembers and a checks for possible multiple Ordergroup-Memberships
  def non_members
    User.natural_order.reject { |u| users.include?(u) }
  end

  def user_tokens=(ids)
    self.user_ids = ids.split(",")
  end

  def deleted?
    deleted_at.present?
  end

  def mark_as_deleted
    # TODO: Checks for participating in not closed orders
    transaction do
      memberships.destroy_all
      # @todo what should happen to the users?
      super
    end
  end
end
