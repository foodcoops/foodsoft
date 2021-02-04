class AddNoteToDeliveries < ActiveRecord::Migration[4.2]
  def self.up
    add_column :deliveries, :note, :text
  end

  def self.down
    remove_column :deliveries, :note
  end
end
