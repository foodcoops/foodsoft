# this is the base class of all configurable settings
class ConfigurableSetting < ActiveRecord::Base
  belongs_to :configurable, :polymorphic => true
  belongs_to :targetable, :polymorphic => true

  # ==For migration up
  # in your migration self.up method:
  #   <tt>ConfigurableSetting.create_table</tt>
  def self.create_table
    self.connection.create_table :configurable_settings, :options => 'ENGINE=InnoDB' do |t|
      t.column :configurable_id,      :integer
      t.column :configurable_type,    :string
      t.column :targetable_id,        :integer
      t.column :targetable_type,      :string
      t.column :name,                 :string, :null => false
      t.column :value_type,           :string
      t.column :value,                :text, :null => true
    end
    self.connection.add_index :configurable_settings, :name
  end
  
  # ==For migration down
  # in your migration self.down method:
  #   <tt>ConfigurableSetting.drop_table</tt>
  def self.drop_table
    self.connection.remove_index :configurable_settings, :name
    self.connection.drop_table :configurable_settings
  end
  
  # returns a string with the classname of configurable
  def self.configurable_class(configurable) # :nodoc:
    ActiveRecord::Base.send(:class_name_of_active_record_descendant, configurable.class).to_s
  end
  
  # returns a string with the classname of configurable
  def self.targetable_class(targetable) # :nodoc:
    ActiveRecord::Base.send(:class_name_of_active_record_descendant, targetable.class).to_s
  end
  
  # returns the instance of the "owner" of the setting
  def self.find_configurable(configured_class, configured_id) # :nodoc:
    configured_class.constantize.find(configured_id)
  end
  
  # returns the instance of the "target" of the setting
  def self.find_targetable(targeted_class, targeted_id) # :nodoc:
    targeted_class.constantize.find(targeted_id)
  end
  
end