class RemoveStaleMemberships < ActiveRecord::Migration
  def up
    Membership.where("group_id NOT IN (?)", Group.ids).delete_all
  end
end
