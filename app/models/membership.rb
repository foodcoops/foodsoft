class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :group

  before_destroy :check_last_admin

  protected

  # check if this is the last admin-membership and deny
  def check_last_admin
    raise I18n.t('model.membership.no_admin_delete') if self.group.role_admin? && self.group.memberships.size == 1 && Group.where(role_admin: true).count == 1
  end
end
