class Message < ActiveRecord::Base
  belongs_to :sender, :class_name => "User", :foreign_key => "sender_id"

  serialize :recipients_ids, Array
  attr_accessor :sent_to_all, :group_id, :recipients_nicks
  
  named_scope :pending, :conditions => { :email_state => 0 }
  named_scope :sent, :conditions => { :email_state => 1 }
  named_scope :public, :conditions => {:private => false}

  # Values for the email_state attribute: :none, :pending, :sent, :failed
  EMAIL_STATE = {
    :pending => 0,
    :sent => 1,
    :failed => 2
  }

  validates_presence_of :recipients_ids, :subject, :body
  validates_length_of :subject, :in => 1..255
  validates_inclusion_of :email_state, :in => EMAIL_STATE.values


  # clean up the recipients_ids
  def before_validation_on_create
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

  def recipients_nicks=(nicks)
    @recipients_nicks = nicks
    add_recipients nicks.split(",").collect { |nick| User.find_by_nick(nick) }
  end

  def recipient=(user)
    @recipients_nicks = user.nick
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
  rescue ActiveRecord::RecordNotFound => error
    logger.warn "#{Foodsoft.env}: #{error.message}"
    User.find(recipients_ids.select { |id| User.exists?(id) }.uniq)
  end
  
  # Sends all pending messages that are to be send as emails.
  def self.send_emails
    messages = Message.pending
    for message in messages
      for recipient in message.recipients
        if recipient.settings['messages.sendAsEmail'] == "1" && !recipient.email.blank?
          begin
            Mailer.deliver_message(message, recipient)
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

