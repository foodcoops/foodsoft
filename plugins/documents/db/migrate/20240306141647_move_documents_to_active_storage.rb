class MoveDocumentsToActiveStorage < ActiveRecord::Migration[7.0]
  def up
    change_table :documents do |t|
      t.boolean :folder, default: false, null: false
    end

    Document.find_each do |document|
      if document.data.present? && document.mime.present?
        document.attachment.attach(create_blob_from_document(document))
      else
        document.update(folder: true)
      end
    end

    change_table :documents, bulk: true do |t|
      t.remove :data
      t.remove :mime
    end
  end

  def down
    change_table :documents, bulk: true do |t|
      t.binary :data, limit: 16.megabyte
      t.string :mime
      t.remove :folder
    end

    Document.find_each do |document|
      next unless document.attachment.attached?

      document.update(
        data: document.attachment.download,
        mime: document.attachment.blob.content_type
      )
    end
  end

  def create_blob_from_document(document)
    ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new(document.data),
      filename: document.name,
      content_type: document.mime
    )
  end
end
