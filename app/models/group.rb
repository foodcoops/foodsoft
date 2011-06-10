# Groups organize the User. 
# A Member gets the roles from the Group
class Group < ActiveRecord::Base
  has_many :memberships, :dependent => :destroy
  has_many :users, :through => :memberships

  validates :name, :presence => true, :length => {:in => 1..25}, :uniqueness => true
  
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


# == Schema Information
#
# Table name: groups
#
#  id                  :integer(4)      not null, primary key
#  type                :string(255)     default(""), not null
#  name                :string(255)     default(""), not null
#  description         :string(255)
#  account_balance     :decimal(8, 2)   default(0.0), not null
#  account_updated     :datetime
#  created_on          :datetime        not null
#  role_admin          :boolean(1)      default(FALSE), not null
#  role_suppliers      :boolean(1)      default(FALSE), not null
#  role_article_meta   :boolean(1)      default(FALSE), not null
#  role_finance        :boolean(1)      default(FALSE), not null
#  role_orders         :boolean(1)      default(FALSE), not null
#  weekly_task         :boolean(1)      default(FALSE)
#  weekday             :integer(4)
#  task_name           :string(255)
#  task_description    :string(255)
#  task_required_users :integer(4)      default(1)
#  deleted_at          :datetime
#  contact_person      :string(255)
#  contact_phone       :string(255)
#  contact_address     :string(255)
#  stats               :text
#  task_duration       :integer(4)      default(1)
#

