class Message < ActiveRecord::Base
  belongs_to :sender, :class_name => "User", :foreign_key => "sender_id"
  belongs_to :group, :class_name => "Group", :foreign_key => "group_id"
  belongs_to :reply_to_message, :class_name => "Message", :foreign_key => "reply_to"

  serialize :recipients_ids, Array
  attr_accessor :sent_to_all, :recipient_tokens

  scope :pending, -> { where(:email_state => 0) }
  scope :sent, -> { where(:email_state => 1) }
  scope :pub, -> { where(:private => false) }

  # Values for the email_state attribute: :none, :pending, :sent, :failed
  EMAIL_STATE = {
    :pending => 0,
    :sent => 1,
    :failed => 2
  }

  validates_presence_of :recipients_ids, :subject, :body
  validates_length_of :subject, :in => 1..255
  validates_inclusion_of :email_state, :in => EMAIL_STATE.values

  before_validation :clean_up_recipient_ids, :on => :create

  def self.deliver(message_id)
    find(message_id).deliver
  end

  def clean_up_recipient_ids
    add_recipients Group.find(group_id).users unless group_id.blank?
    self.recipients_ids = recipients_ids.uniq.reject { |id| id.blank? } unless recipients_ids.nil?
    self.recipients_ids = User.all.collect(&:id) if sent_to_all == "1"
  end

  def add_recipients(users)
    self.recipients_ids = [] if recipients_ids.blank?
    self.recipients_ids += users.collect(&:id) unless users.blank?
  end

  def group_id=(group_id)
    @group_id = group_id
    add_recipients Group.find(group_id).users unless group_id.blank?
  end

  def order_id=(order_id)
    @order_id = order_id
    add_recipients Order.find(order_id).users_ordered unless order_id.blank?
  end

  def recipient_tokens=(ids)
    @recipient_tokens = ids
    add_recipients ids.split(",").collect { |id| User.find(id) }
  end

  def mail_to=(user_id)
    user = User.find(user_id)
    add_recipients([user])
  end

  # Returns true if this message is a system message, i.e. was sent automatically by Foodsoft itself.
  def system_message?    
    self.sender_id.nil?
  end

  def sender_name
    system_message? ? I18n.t('layouts.foodsoft') : sender.display rescue "?"
  end

  def recipients
    User.where(id: recipients_ids)
  end

  def deliver
    for user in recipients
      if user.receive_email?
        begin
          MessagesMailer.foodsoft_message(self, user).deliver
        rescue
          Rails.logger.warn "Deliver failed for user \##{user.id}: #{user.email}"
        end
      end
    end
    update_attribute(:email_state, 1)
  end

  def is_readable_for?(user)
    !private || sender == user || recipients_ids.include?(user.id)
  end
end


