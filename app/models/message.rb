class Message < ActiveRecord::Base
  belongs_to :sender, :class_name => "User", :foreign_key => "sender_id"

  serialize :recipients_ids, Array
  attr_accessor :sent_to_all, :group_id, :recipient_tokens
  
  scope :pending, where(:email_state => 0)
  scope :sent, where(:email_state => 1)
  scope :public, where(:private => false)

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

  def clean_up_recipient_ids
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

  def recipient_tokens=(ids)
    @recipient_tokens = ids
    add_recipients ids.split(",").collect { |id| User.find(id) }
  end

  def reply_to=(message_id)
    message = Message.find(message_id)
    add_recipients(message.sender.to_a)
    self.subject = "Re: #{message.subject}"
    self.body = "#{message.sender.nick} schrieb am #{I18n.l(message.created_at.to_date)} um #{I18n.l(message.created_at, :format => :time)}:\n"
    message.body.each_line{ |l| self.body += "> #{l}" }
  end

  def mail_to=(user_id)
    user = User.find(user_id)
    add_recipients(user.to_a)
  end

  # Returns true if this message is a system message, i.e. was sent automatically by the FoodSoft itself.
  def system_message?    
    self.sender_id.nil?
  end

  def sender_name
    system_message? ? 'Foodsoft' : sender.nick rescue "??"
  end

  def recipients
    User.find(recipients_ids)
  end
  
  # Sends all pending messages that are to be send as emails.
  def self.send_emails
    messages = Message.pending
    for message in messages
      for recipient in message.recipients
        if recipient.settings['messages.sendAsEmail'] == "1" && !recipient.email.blank?
          begin
            Mailer.foodsoft_message(message, recipient).deliver
          rescue
            logger.warn "Deliver failed for #{recipient.nick}: #{recipient.email}"
          end
        end
      end
      message.update_attribute(:email_state, 1)
    end
  end
end


# == Schema Information
#
# Table name: messages
#
#  id             :integer(4)      not null, primary key
#  sender_id      :integer(4)
#  recipients_ids :text
#  subject        :string(255)     not null
#  body           :text
#  email_state    :integer(4)      default(0), not null
#  private        :boolean(1)      default(FALSE)
#  created_at     :datetime
#

