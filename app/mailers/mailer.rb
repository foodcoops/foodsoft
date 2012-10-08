# encoding: utf-8
# ActionMailer class that handles all emails for the FoodSoft.
class Mailer < ActionMailer::Base

  layout 'email'  # Use views/layouts/email.txt.erb

  default from: "FoodSoft <#{FoodsoftConfig[:email_sender]}>",
          sender: FoodsoftConfig[:email_sender],
          errors_to: FoodsoftConfig[:email_sender]
  
  # Sends an email copy of the given internal foodsoft message.
  def foodsoft_message(message, recipient)
    @message = message

    mail subject: "[#{FoodsoftConfig[:name]}] " + message.subject,
         to: recipient.email,
         from: "#{message.sender.nick} <#{message.sender.email}>"
  end

  # Sends an email with instructions on how to reset the password.
  # Assumes user.setResetPasswordToken has been successfully called already.
  def reset_password(foodcoop, user_id)
    set_foodcoop_scope(foodcoop)
    @user = User.find(user_id)
    @link = new_password_url(id: @user.id, token: @user.reset_password_token)

    mail :to => @user.email,
         :subject => "[#{FoodsoftConfig[:name]}] Neues Passwort für/ New password for #{@user.nick}"
  end
    
  # Sends an invite email.
  def invite(foodcoop, invite_id)
    set_foodcoop_scope(foodcoop)
    @invite = Invite.find(invite_id)
    @link = accept_invitation_url(token: @invite.token)

    mail :to => @invite.email,
         :subject => "Einladung in die Foodcoop #{FoodsoftConfig[:name]} - Invitation to the Foodcoop"
  end

  # Notify user of upcoming task.
  def upcoming_tasks(user, task)
    @user = user
    @task = task

    mail :to => user.email,
         :subject =>  "[#{FoodsoftConfig[:name]}] Aufgaben werden fällig!"
  end

  # Sends order result for specific Ordergroup
  def order_result(user, group_order)
    @order        = group_order.order
    @group_order  = group_order

    mail :to => user.email,
         :subject => "[#{FoodsoftConfig[:name]}] Bestellung beendet: #{group_order.order.name}"
  end

  # Notify user if account balance is less than zero
  def negative_balance(user,transaction)
    @group        = user.ordergroup
    @transaction  = transaction

    mail :to => user.email,
         :subject => "[#{FoodsoftConfig[:name]}] Gruppenkonto im Minus"
  end

  def feedback(user, feedback)
    @user = user
    @feedback = feedback

    mail :to => FoodsoftConfig[:notification]["error_recipients"],
         :from => "#{user.nick} <#{user.email}>",
         :sender => FoodsoftConfig[:notification]["sender_address"],
         :errors_to => FoodsoftConfig[:notification]["sender_address"],
         :subject => "[Foodsoft] Feeback von #{user.email}"
  end

  def not_enough_users_assigned(task, user)
    @task = task
    @user = user

    mail :to => user.email,
         :subject => "[#{FoodsoftConfig[:name]}] \"#{task.name}\" braucht noch Leute!"
  end

  private

  def set_foodcoop_scope(foodcoop)
    ActionMailer::Base.default_url_options[:foodcoop] = foodcoop
  end
  
end
