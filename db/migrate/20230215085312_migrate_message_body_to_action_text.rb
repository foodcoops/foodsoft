class MigrateMessageBodyToActionText < ActiveRecord::Migration[7.0]
  include ActionView::Helpers::TextHelper

  class Message < ApplicationRecord
    has_rich_text :body
  end

  def change
    reversible do |dir|
      dir.up do
        rename_column :messages, :body, :body_old
        Message.all.each do |message|
          elem = Nokogiri::XML::DocumentFragment.parse(simple_format(message.body_old))
          elem.content = elem.content.encode('ascii', fallback: ->(char) { "&##{char.ord};" })
          message.update(body: elem)
          message.body.update(record_type: :Message) # action_text_rich_texts uses STI record_type field and has to be set to the real model
        end
        remove_column :messages, :body_old, :text
      end
      dir.down do
        execute 'ALTER TABLE `messages` ADD `body_old` text'
        execute "UPDATE `messages` m
                  INNER JOIN `action_text_rich_texts` a
                    ON m.id = a.record_id
                set m.body_old = a.body"
        Message.all.each do |message|
          message.update(body_old: strip_tags(message.body_old))
        end
        execute "DELETE FROM `action_text_rich_texts` WHERE `action_text_rich_texts`.`record_type` = 'Message'"
        execute 'ALTER TABLE `messages` CHANGE `body_old` `body` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL;'
      end
    end
  end
end
