class Membership < ActiveRecord::Base
  
  belongs_to :user
  belongs_to :group

  before_destroy :check_last_admin
  
  # messages
  ERR_NO_ADMIN_MEMBER_DELETE = "Mitgliedschaft kann nicht beendet werden. Du bist die letzte Administratorin"

  protected

  # check if this is the last admin-membership and deny
  def check_last_admin
    raise ERR_NO_ADMIN_MEMBER_DELETE if self.group.role_admin? && self.group.memberships.size == 1 && Group.find_all_by_role_admin(true).size == 1 
  end
end

