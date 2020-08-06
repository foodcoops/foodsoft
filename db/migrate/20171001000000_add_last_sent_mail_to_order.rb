class AddLastSentMailToOrder < ActiveRecord::Migration[4.2]
  def change
    add_column :orders, :last_sent_mail, :datetime
  end
end
