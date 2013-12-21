# Groups organize the User. 
# A Member gets the roles from the Group
class Group < ActiveRecord::Base
  has_many :memberships
  has_many :users, :through => :memberships

  validates :name, :presence => true, :length => {:in => 1..25}
  
  attr_reader :user_tokens

  scope :undeleted, -> { where(deleted_at: nil) }

  # Returns true if the given user if is an member of this group.
  def member?(user)
    memberships.find_by_user_id(user.id)
  end
  
  # Returns all NONmembers and a checks for possible multiple Ordergroup-Memberships
  def non_members
    User.natural_order.all.reject { |u| users.include?(u) }
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
      # TODO: What should happen to users?
      update_column :deleted_at, Time.now
    end
  end
end


