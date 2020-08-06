class AddBoxfillToOrder < ActiveRecord::Migration[4.2]
  def change
    add_column :orders, :boxfill, :datetime
  end
end
