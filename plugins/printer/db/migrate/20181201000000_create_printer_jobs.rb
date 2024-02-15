class CreatePrinterJobs < ActiveRecord::Migration[4.2]
  def change
    create_table :printer_jobs do |t|
      t.references :order
      t.string :document, null: false
      t.integer :created_by_user_id, null: false
      t.integer :finished_by_user_id
      t.datetime :finished_at, index: true
    end

    create_table :printer_job_updates do |t|
      t.references :printer_job, null: false
      t.datetime :created_at, null: false
      t.string :state, null: false
      t.text :message
    end

    add_index :printer_job_updates, [:printer_job_id, :created_at]
  end
end
