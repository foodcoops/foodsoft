# @private
class CreateAdyenNotifications < ActiveRecord::Migration
  
  def self.up
    create_table :adyen_notifications do |t|
      t.boolean  :live,                  :null => false, :default => false
      t.string   :event_code,            :null => false, :limit => 40
      t.string   :psp_reference,         :null => false, :limit => 50
      t.string   :original_reference,    :null => true
      t.string   :merchant_reference,    :null => false
      t.string   :merchant_account_code, :null => false
      t.datetime :event_date,            :null => false
      t.boolean  :success,               :null => false, :default => false
      t.string   :payment_method,        :null => true
      t.string   :operations,            :null => true
      t.text     :reason,                :null => true
      t.string   :currency,              :null => true, :limit => 3
      t.integer  :value,                 :null => true
      t.boolean  :processed,             :null => false, :default => false
      t.timestamps
    end
     
    add_index :adyen_notifications, [:psp_reference, :event_code, :success], :unique => true, :name => 'adyen_notification_uniqueness'
  end

  def self.down
    drop_table :adyen_notifications
  end
end
