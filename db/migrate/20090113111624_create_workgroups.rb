class CreateWorkgroups < ActiveRecord::Migration
  def self.up
    # Migrate all groups to workgroups
    Group.find(:all, :conditions => { :type => "" }).each do |workgroup|
      workgroup.update_attribute(:type, "Workgroup")
    end
  end

  def self.down
    Group.find(:all, :conditions => { :type => "Workgroup" }).each do |workgroup|
      workgroup.update_attribute(:type, "")
    end
  end
end
