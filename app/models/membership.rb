class Membership < ActiveRecord::Base
  
  # gettext-option
  untranslate_all
  
  belongs_to :user
  belongs_to :group
  
  # messages
  ERR_NO_ADMIN_MEMBER_DELETE = "Mitgliedschaft kann nicht beendet werden. Du bist die letzte Administratorin"
  
  # check if this is the last admin-membership and deny
  def before_destroy
    raise ERR_NO_ADMIN_MEMBER_DELETE if self.group.role_admin? && self.group.memberships.size == 1 && Group.find_all_by_role_admin(true).size == 1 
  end
end
