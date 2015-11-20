class AddBoxfillToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :boxfill, :datetime
  end
end
