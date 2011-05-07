# Groups organize the User. 
# A Member gets the roles from the Group
class Group < ActiveRecord::Base
  has_many :memberships, :dependent => :destroy
  has_many :users, :through => :memberships
  
  validates_length_of :name, :in => 1..25
  validates_uniqueness_of :name
  
  # Returns true if the given user if is an member of this group.
  def member?(user)
    memberships.find_by_user_id(user.id)
  end
  
  # Returns all NONmembers and a checks for possible multiple Ordergroup-Memberships
  def non_members
    User.all(:order => 'nick').reject { |u| users.include?(u) }
  end
  
  # Check before destroy a group, if this is the last group with admin role
  def before_destroy
    if self.role_admin == true && Group.find_all_by_role_admin(true).size == 1
      raise "Die letzte Gruppe mit Admin-Rechten darf nicht gelöscht werden"
    end
  end
  
  protected
  
  # validates uniqueness of the Group.name. Checks groups and ordergroups
  def validate
    errors.add(:name, "ist schon vergeben") if (group = Group.find_by_name(name) || group = Ordergroup.find_by_name(name)) && self != group
  end

  # add validation check on update
  def validate_on_update
    # error if this is the last group with admin role and role_admin should set to false
    if self.role_admin == false && Group.find_all_by_role_admin(true).size == 1 && self == Group.find(:first, :conditions => "role_admin = 1")
      errors.add(:role_admin, "Der letzten Gruppe mit Admin-Rechten darf die Admin-Rolle nicht entzogen werden")
    end
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

