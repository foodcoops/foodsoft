class AddLastSentMailToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :last_sent_mail, :datetime
  end
end
