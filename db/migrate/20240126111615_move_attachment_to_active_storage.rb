class MoveAttachmentToActiveStorage < ActiveRecord::Migration[7.0]
  def up
    Invoice.find_each do |invoice|
      if invoice.attachment_data.present? && invoice.attachment_mime.present?
        blob = ActiveStorage::Blob.create_and_upload!(
          io: StringIO.new(invoice.attachment_data),
          filename: 'attachment',
          content_type: invoice.attachment_mime
        )

        invoice.attachments.attach(blob)
      end
    end

    change_table :invoices, bulk: true do |t|
      t.remove :attachment_data
      t.remove :attachment_mime
    end
  end

  def down
    change_table :invoices, bulk: true do |t|
      t.binary :attachment_data, limit: 16.megabytes
      t.string :attachment_mime
    end

    Invoice.find_each do |invoice|
      if invoice.attachments.attached?
        attachment = invoice.attachments.first # Will only migrate the first attachment back, as multiple were not supported before
        attachment_data = attachment.download
        attachment_mime = attachment.blob.content_type

        invoice.update(
          attachment_data: attachment_data,
          attachment_mime: attachment_mime
        )
      end
    end
  end
end
