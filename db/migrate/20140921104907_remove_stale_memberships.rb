class RemoveStaleMemberships < ActiveRecord::Migration[4.2]
  def up
    Membership.where.not(group_id: Group.ids).delete_all
  end
end
