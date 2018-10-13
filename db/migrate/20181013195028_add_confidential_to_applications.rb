class AddConfidentialToApplications < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :confidential, :boolean, null: false, default: true
  end
end
