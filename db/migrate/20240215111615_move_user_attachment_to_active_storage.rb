class MoveUserAttachmentToActiveStorage < ActiveRecord::Migration[7.0]
  def up
    User.find_each do |user|
      if user.attachment_data.present? && user.attachment_mime.present?
        blob = ActiveStorage::Blob.create_and_upload!(
          io: StringIO.new(user.attachment_data),
          filename: 'attachment',
          content_type: user.attachment_mime
        )

        user.attachments.attach(blob)
      end
    end

    change_table :users, bulk: true do |t|
      t.remove :attachment_data
      t.remove :attachment_mime
    end
  end

  def down
    change_table :users, bulk: true do |t|
      t.binary :attachment_data, limit: 16.megabyte
      t.string :attachment_mime
    end

    User.find_each do |user|
      if user.attachments.attached?
        attachment = user.attachments.first # Will only migrate the first attachment back, as multiple were not supported before
        attachment_data = attachment.download
        attachment_mime = attachment.blob.content_type

        user.update(
          attachment_data: attachment_data,
          attachment_mime: attachment_mime
        )
      end
    end
  end
end

