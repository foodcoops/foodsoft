class CreateDocuments < ActiveRecord::Migration[4.2]
  def self.up
    create_table :documents do |t|
      t.string :name
      t.string :mime
      t.binary :data, limit: 16.megabyte
      t.integer :created_by_user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :documents
  end
end
