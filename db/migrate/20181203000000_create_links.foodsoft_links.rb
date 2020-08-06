class CreateLinks < ActiveRecord::Migration[4.2]
  def change
    create_table :links do |t|
      t.string :name, null: false
      t.string :url, null: false
      t.references :workgroup
      t.boolean :indirect, null: false, default: false
      t.string :authorization
    end
  end
end
