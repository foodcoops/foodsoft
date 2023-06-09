class Workgroup < Group
  include CustomFields

  has_many :tasks
  # returns all non-finished tasks
  has_many :open_tasks, -> { where(done: false).order('due_date', 'name') }, class_name: 'Task'

  validates :name, uniqueness: true
  validate :last_admin_on_earth, on: :update
  before_destroy :check_last_admin_group

  protected

  # Check before destroy a group, if this is the last group with admin role
  def check_last_admin_group
    return unless role_admin && Workgroup.where(role_admin: true).size == 1

    raise I18n.t('workgroups.error_last_admin_group')
  end

  # add validation check on update
  # Return an error if this is the last group with admin role and role_admin should set to false
  def last_admin_on_earth
    return unless !role_admin && !Workgroup.where(role_admin: true).where.not(id: id).exists?

    errors.add(:role_admin, I18n.t('workgroups.error_last_admin_role'))
  end
end
