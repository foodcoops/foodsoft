class RenameOrderLastSentMail < ActiveRecord::Migration[7.0]
  change_table :orders do |t|
    t.rename :last_sent_mail, :remote_ordered_at
  end
end
