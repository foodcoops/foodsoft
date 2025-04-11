class Document < ApplicationRecord
  include ActsAsTree
  extend ActsAsTree::TreeWalker

  belongs_to :created_by, class_name: 'User', foreign_key: 'created_by_user_id'

  acts_as_tree

  def file?
    !folder?
  end

  def folder?
    mime.nil?
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
end
