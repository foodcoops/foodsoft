class CreateJoinTableGroupsPayments < ActiveRecord::Migration[5.2]
  def change
    create_join_table :groups, :payments do |t|
      # t.index [:group_id, :payment_id]
      # t.index [:payment_id, :group_id]
    end
  end
end
