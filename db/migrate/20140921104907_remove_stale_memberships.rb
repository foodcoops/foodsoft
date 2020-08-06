class RemoveStaleMemberships < ActiveRecord::Migration[4.2]
  def up
    Membership.where("group_id NOT IN (?)", Group.ids).delete_all
  end
end
