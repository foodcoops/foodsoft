# ActionMailer class that handles all emails for the FoodSoft.
class Mailer < ActionMailer::Base

  layout 'email'  # Use views/layouts/email.html.erb

  default :from => "FoodSoft <#{Foodsoft.config[:email_sender]}>"
  
  # Sends an email copy of the given internal foodsoft message.
  def message(message, recipient)
    @body = message.body
    @sender = message.sender.nick
    @recipients = recipient.nick
    @reply = url_for(:controller => "messages", :action => "reply", :id => message.id)
    @link = url_for(:controller => "messages", :action => "show", :id => message.id)
    @profile = url_for(:controller => "home", :action => "profile")

    mail :sender => Foodsoft.config[:email_sender],
         :errors_to => Foodsoft.config[:email_sender],
         :subject => "[#{Foodsoft.config[:name]}] " + message.subject,
         :to => recipient.email,
         :from => "#{message.sender.nick} <#{message.sender.email}>"
  end

  # Sends an email with instructions on how to reset the password.
  # Assumes user.setResetPasswordToken has been successfully called already.
  def reset_password(user)
    @user = user
    @link = url_for(:controller => "login", :action => "password", :id => user.id, :token => user.reset_password_token)

    mail :to => user.email,
         :subject => "[#{Foodsoft.config[:name]}] Neues Passwort für/ New password for #{user.nick}"
  end
    
  # Sends an invite email.
  def invite(invite)
    @invite = invite
    @link = url_for(:controller => "login", :action => "invite", :id => invite.token)

    mail :to => invite.email,
         :subject => "Einladung in die Foodcoop #{Foodsoft.config[:name]} - Invitation to the Foodcoop"
  end

  # Notify user of upcoming task.
  def upcoming_tasks(user, task)
    @user = user
    @task = task

    mail :to => user.email,
         :subject =>  "[#{Foodsoft.config[:name]}] Aufgaben werden fällig!"
  end

  # Sends order result for specific Ordergroup
  def order_result(user, group_order)
    @order        = group_order.order
    @group_order  = group_order

    mail :to => user.email,
         :subject => "[#{Foodsoft.config[:name]}] Bestellung beendet: #{group_order.order.name}"
  end

  # Notify user if account balance is less than zero
  def negative_balance(user,transaction)
    @group        = user.ordergroup
    @transaction  = transaction

    mail :to => user.email,
         :subject => "[#{Foodsoft.config[:name]}] Gruppenkonto im Minus"
  end

  def feedback(user, message)
    @user = user
    @message = message

    mail :to => Foodsoft.config[:notification]["error_recipients"],
         :from => "#{user.nick} <#{user.email}>",
         :sender => Foodsoft.config[:notification]["sender_address"],
         :errors_to => Foodsoft.config[:notification]["sender_address"],
         :subject => "[Foodsoft] Feeback von #{user.email}"
  end

  def not_enough_users_assigned(task,user)
    @task = task
    @user = user
    @task_url = url_for(:controller => "tasks", :action => "workgroup", :id => task.workgroup_id)
    
    mail :to => user.email,
         :subject => "[#{Foodsoft.config[:name]}] #{task.name} braucht noch Leute!"
  end
  
end
