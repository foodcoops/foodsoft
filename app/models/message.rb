# A message within the foodsoft.
# 
# * sender (User) - the sending User (might be nil if it is a system message)
# * recipient (User) - the receiving User
# * recipients (String) - list of all recipients of this message as User.nick/Group.name
# * subject (string) - message subject
# * body (string) - message body
# * read? (boolean) - message read status
# * email_state (integer) - email state, one of EMAIL_STATE.values
# * created_on (timestamp) - creation timestamp
class Message < ActiveRecord::Base
  belongs_to :sender, :class_name => "User", :foreign_key => "sender_id"
  belongs_to :recipient, :class_name => "User", :foreign_key => "recipient_id"
  
  attr_accessible :recipient_id, :recipient, :subject, :body, :recipients

  
  # Values for the email_state attribute: :none, :pending, :sent, :failed
  EMAIL_STATE = {
    :none => 0,
    :pending => 1,
    :sent => 2,
    :failed => 3
  }

  validates_presence_of :recipient_id
  validates_length_of :subject, :in => 1..255
  validates_presence_of :recipients
  validates_presence_of :body  
  validates_inclusion_of :email_state, :in => EMAIL_STATE.values
  
  @@pending = false
  
  # Automatically determine if this message should be send as an email.
  def before_validation_on_create
    if (recipient && recipient.settings["messages.sendAsEmail"] == '1')
      self.email_state = EMAIL_STATE[:pending]
    else
      self.email_state = EMAIL_STATE[:none]
    end
  end

  # Determines if this new message is a pending email.
  def after_create
    @@pending = @@pending || self.email_state == EMAIL_STATE[:pending]
  end

  # Returns true if there might be pending emails.
  def self.pending?
    @@pending
  end
  
  # Returns true if this message is a system message, i.e. was sent automatically by the FoodSoft itself.
  def system_message?    
    self.sender_id.nil?
  end  
  
  # Sends all pending messages that are to be send as emails.
  def self.send_emails
    transaction do
      messages = find(:all, :conditions => ["email_state = ?", EMAIL_STATE[:pending]], :lock => true)
      logger.debug("Sending #{messages.size} pending messages as emails...") unless messages.empty?
      for message in messages
        if (message.recipient && message.recipient.email && !message.recipient.email.empty?)
          begin
            Mailer.deliver_message(message)
            message.update_attribute(:email_state, EMAIL_STATE[:sent])
            logger.debug("Delivered message as email: id = #{message.id}, recipient = #{message.recipient.nick}, subject = \"#{message.subject}\"")
          rescue => exception
            message.update_attribute(:email_state, EMAIL_STATE[:failed])
            logger.warn("Failed to deliver message as email: id = #{message.id}, recipient = #{message.recipient.nick}, subject = \"#{message.subject}\", exception = #{exception.message}")
          end
        else
          message.update_attribute(:email_state, EMAIL_STATE[:failed])
          logger.warn("Cannot deliver message as email (no user email): id = #{message.id}, recipient = #{message.recipient.nick}, subject = \"#{message.subject}\"")
        end
      end
      logger.debug("Done sending emails.") unless messages.empty?
      @@pending = false
    end
  end

  # Returns a new message object created from the attributes specified (recipient, recipients, subject)
  # and the body from the given template that can make use of the variables specified.
  # The templates are to be stored in app/views/messages, i.e. the template name 
  # "order_finished" would invoke template file "app/views/messages/order_finished.rhtml".
  # Note: you need to set the sender afterwards if this should not be a system message.
  #
  # Example:
  #   Message.from_template(
  #     'order_finished', 
  #     {:user => user, :group => order_group, :order => self, :results => results, :total => group_order.price}, 
  #     {:recipient_id => user.id, :recipients => recipients, :subject => "Bestellung beendet: #{self.name}"}
  #   ).save!
  def self.from_template(template, vars, attributes)
    view = ActionView::Base.new(Rails::Configuration.new.view_path, {}, MessagesController.new)    
    new(attributes.merge(:body => view.render(:file => "messages/#{template}.rhtml", :locals => vars)))
  end
end
