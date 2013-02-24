# Groups organize the User. 
# A Member gets the roles from the Group
class Group < ActiveRecord::Base
  has_many :memberships, :dependent => :destroy
  has_many :users, :through => :memberships

  validates :name, :presence => true, :length => {:in => 1..25}
  
  attr_reader :user_tokens
  
  # Returns true if the given user if is an member of this group.
  def member?(user)
    memberships.find_by_user_id(user.id)
  end
  
  # Returns all NONmembers and a checks for possible multiple Ordergroup-Memberships
  def non_members
    User.all(:order => 'nick').reject { |u| users.include?(u) }
  end

  def user_tokens=(ids)
    self.user_ids = ids.split(",")
  end
  
end


