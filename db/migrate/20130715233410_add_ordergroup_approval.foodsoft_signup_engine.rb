# This migration comes from foodsoft_signup_engine (originally 20130715233410)
class AddOrdergroupApproval < ActiveRecord::Migration
  def self.up
    add_column :groups, :approved, :boolean, :default => false
    Ordergroup.all.each { |o| o.approved = true }
  end

  def self.down
    remove_column :groups, :approved
  end
end
