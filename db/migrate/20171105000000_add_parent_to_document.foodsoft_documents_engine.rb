class AddParentToDocument < ActiveRecord::Migration
  def change
    add_reference :documents, :parent, index: true
  end
end
