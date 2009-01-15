# ActionMailer class that handles all emails for the FoodSoft.
class Mailer < ActionMailer::Base
  
  # Sends an email with instructions on how to reset the password.
  # Assumes user.setResetPasswordToken has been successfully called already.
  def password(user)
    request = ApplicationController.current.request
    subject     "[#{APP_CONFIG[:name]}] Neues Passwort für/ New password for " + user.nick
    recipients  user.email
    from        "FoodSoft <#{APP_CONFIG[:email_sender]}>"
    body        :user => user, 
                :link => url_for(:host => request.host, :controller => "login", :action => "password", :id => user.id, :token => user.reset_password_token),
                :foodsoftUrl => url_for(:host => request.host, :controller => "index")
  end
  
  # Sends an email copy of the given internal foodsoft message.
  def message(message)
    request = ApplicationController.current.request
    subject     "[#{APP_CONFIG[:name]}] " + message.subject
    recipients  message.recipient.email
    from        (message.system_message? ? "FoodSoft <#{APP_CONFIG[:email_sender]}>" : "#{message.sender.nick} <#{message.sender.email}>")
    body        :body => message.body, :sender => (message.system_message? ? 'Foodsoft' : message.sender.nick), 
                :recipients => message.recipients,
                :reply => url_for(:host => request.host, reply_message_path(message),
                :profile => url_for(:host => request.host, my_profile_path),
                :link => url_for(:host => request.host, message_path(message),
                :foodsoftUrl => url_for(:host => request.host, :controller => "index")
  end
  
  # Sends an invite email.
  def invite(invite)
    request = ApplicationController.current.request
    subject     "Einladung in die Foodcoop #{APP_CONFIG[:name]} - Invitation to the Foodcoop"
    recipients  invite.email
    from        "FoodSoft <#{APP_CONFIG[:email_sender]}>"
    body        :invite => invite,
                :link => url_for(:host => request.host, :controller => "login", :action => "invite", :id => invite.token),
                :foodsoftUrl => url_for(:host => request.host, :controller => "index")
  end
  
end
