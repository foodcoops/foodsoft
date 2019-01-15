require "base32"

class Message < ApplicationRecord
  belongs_to :sender, :class_name => "User", :foreign_key => "sender_id"
  belongs_to :group, :class_name => "Group", :foreign_key => "group_id"
  belongs_to :reply_to_message, :class_name => "Message", :foreign_key => "reply_to"

  serialize :recipients_ids, Array
  attr_accessor :send_method, :recipient_tokens, :order_id

  scope :pending, -> { where(:email_state => 0) }
  scope :sent, -> { where(:email_state => 1) }
  scope :pub, -> { where(:private => false) }
  scope :threads, -> { where(:reply_to => nil) }
  scope :thread, -> (id) { where("id = ? OR reply_to = ?", id, id) }

  # Values for the email_state attribute: :none, :pending, :sent, :failed
  EMAIL_STATE = {
    :pending => 0,
    :sent => 1,
    :failed => 2
  }

  validates_presence_of :recipients_ids, :subject, :body
  validates_length_of :subject, :in => 1..255
  validates_inclusion_of :email_state, :in => EMAIL_STATE.values

  after_initialize do
    @send_method ||= 'recipients'
  end

  before_create :create_salt
  before_validation :clean_up_recipient_ids, :on => :create

  def clean_up_recipient_ids
    add_recipients Group.find(group_id).users unless group_id.blank?
    add_recipients Order.find(order_id).users_ordered if send_method == 'order'
    self.recipients_ids = recipients_ids.uniq.reject { |id| id.blank? } unless recipients_ids.nil?
    self.recipients_ids = User.undeleted.collect(&:id) if send_method == 'all'
  end

  def add_recipients(users)
    self.recipients_ids = [] if recipients_ids.blank?
    self.recipients_ids += users.collect(&:id) unless users.blank?
  end

  def group_id=(group_id)
    group = Group.find(group_id) unless group_id.blank?
    if group
      @send_method = 'workgroup' if group.type == 'Workgroup'
      @send_method = 'ordergroup' if group.type == 'Ordergroup'
      @send_method = 'messagegroup' if group.type == 'Messagegroup'
    end
    super
  end

  def workgroup_id
    group_id if send_method == 'workgroup'
  end

  def ordergroup_id
    group_id if send_method == 'ordergroup'
  end

  def messagegroup_id
    group_id if send_method == 'messagegroup'
  end

  def workgroup_id=(workgroup_id)
    self.group_id = workgroup_id if send_method == 'workgroup'
  end

  def ordergroup_id=(ordergroup_id)
    self.group_id = ordergroup_id if send_method == 'ordergroup'
  end

  def messagegroup_id=(messagegroup_id)
    self.group_id = messagegroup_id if send_method == 'messagegroup'
  end

  def order_id=(order_id)
    @order_id = order_id
    @send_method ||= 'order'
  end

  def recipient_tokens=(ids)
    @recipient_tokens = ids
    add_recipients ids.split(",").collect { |id| User.find(id) }
  end

  def mail_to=(user_id)
    user = User.find(user_id)
    add_recipients([user])
  end

  def mail_hash_for_user(user)
    digest = Digest::SHA1.new
    digest.update self.id.to_s
    digest.update ":"
    digest.update salt
    digest.update ":"
    digest.update user.id.to_s
    Base32.encode digest.digest
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

  def last_reply
    Message.where(reply_to: self.id).order(:created_at).last
  end

  def is_readable_for?(user)
    !private || sender == user || recipients_ids.include?(user.id)
  end

  private

  def create_salt
    self.salt = [Array.new(6){rand(256).chr}.join].pack("m").chomp
  end
end
