class Document < ApplicationRecord
  include ActsAsTree
  extend ActsAsTree::TreeWalker

  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_user_id'

  has_one_attached :attachment

  acts_as_tree

  validate :valid_attachment

  def file?
    !folder?
  end

  def valid_attachment
    errors.add(:attachment, I18n.t('documents.create.not_allowed_mime', mime: attachment.content_type)) unless !attachment.attached? or allowed_mime? attachment.content_type
  end

  def filename
    types = MIME::Types[mime]

    if name.include? '.'
      types.each do |type|
        type.extensions.each do |extension|
          return name if name.end_with? ".#{extension}"
        end
      end
    end

    "#{name}.#{types.first.preferred_extension}"
  end

  def allowed_mime?(mime)
    whitelist = FoodsoftConfig[:documents_allowed_extension].split
    MIME::Types.type_for(whitelist).each do |type|
      return true if type.like? mime
    end
    false
  end

  def delete_attachment
    attachment.purge_later
  end

end
