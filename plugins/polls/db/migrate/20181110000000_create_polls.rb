class CreatePolls < ActiveRecord::Migration
  def change
    create_table :polls do |t|
      t.integer :created_by_user_id, null: false
      t.string :name, null: false
      t.text :description
      t.datetime :starts
      t.datetime :ends
      t.boolean :one_vote_per_ordergroup, default: false, null: false
      t.text :required_ordergroup_custom_fields
      t.text :required_user_custom_fields
      t.integer :voting_method, null: false
      t.string :choices, array: true, null: false
      t.integer :final_choice, index: true
      t.integer :multi_select_count, default: 0, null: false
      t.integer :min_points
      t.integer :max_points
      t.timestamps
    end

    create_table :poll_votes do |t|
      t.references :poll, null: false
      t.references :user, null: false
      t.references :ordergroup
      t.text :note
      t.timestamps
      t.index [:poll_id, :user_id, :ordergroup_id], unique: true
    end

    create_table :poll_choices do |t|
      t.references :poll_vote, null: false
      t.integer :choice, null: false
      t.integer :value, null: false
      t.index [:poll_vote_id, :choice], unique: true
    end
  end
end
