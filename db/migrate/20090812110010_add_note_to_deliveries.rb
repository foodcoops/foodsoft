class AddNoteToDeliveries < ActiveRecord::Migration
  def self.up
    add_column :deliveries, :note, :text
  end

  def self.down
    remove_column :deliveries, :note
  end
end
