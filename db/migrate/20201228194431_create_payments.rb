class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.string :name
      t.deleted_at :datetime
    end
  end
end
