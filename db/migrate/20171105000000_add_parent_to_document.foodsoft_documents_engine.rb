class AddParentToDocument < ActiveRecord::Migration[4.2]
  def change
    add_reference :documents, :parent, index: true
  end
end
