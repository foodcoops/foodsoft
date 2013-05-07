# encoding: utf-8
# ActionMailer class that handles all emails for the FoodSoft.
class Mailer < ActionMailer::Base

  layout 'email'  # Use views/layouts/email.txt.erb

  default from: "FoodSoft <#{FoodsoftConfig[:email_sender]}>",
          sender: FoodsoftConfig[:email_sender],
          errors_to: FoodsoftConfig[:email_sender]
  
  # Sends an email copy of the given internal foodsoft message.
  def foodsoft_message(message, recipient)
    set_foodcoop_scope
    @message = message

    mail subject: "[#{FoodsoftConfig[:name]}] " + message.subject,
         to: recipient.email,
         from: "#{message.sender.nick} <#{message.sender.email}>"
  end

  # Sends an email with instructions on how to reset the password.
  # Assumes user.setResetPasswordToken has been successfully called already.
  def reset_password(user)
    set_foodcoop_scope
    @user = user
    @link = new_password_url(id: @user.id, token: @user.reset_password_token)

    mail :to => @user.email,
         :subject => "[#{FoodsoftConfig[:name]}] " + I18n.t('mailer.reset_password.subject', :username => @user.nick)
  end
    
  # Sends an invite email.
  def invite(invite)
    set_foodcoop_scope
    @invite = invite
    @link = accept_invitation_url(token: @invite.token)

    mail :to => @invite.email,
         :subject => I18n.t('mailer.invite.subject')
  end

  # Notify user of upcoming task.
  def upcoming_tasks(user, task)
    set_foodcoop_scope
    @user = user
    @task = task

    mail :to => user.email,
         :subject =>  "[#{FoodsoftConfig[:name]}] " + I18n.t('mailer.upcoming_tasks.subject')
  end

  # Sends order result for specific Ordergroup
  def order_result(user, group_order)
    set_foodcoop_scope
    @order        = group_order.order
    @group_order  = group_order

    mail :to => user.email,
         :subject => "[#{FoodsoftConfig[:name]}] " + I18n.t('mailer.order_result.subject', :name => group_order.order.name)
  end

  # Notify user if account balance is less than zero
  def negative_balance(user,transaction)
    set_foodcoop_scope
    @group        = user.ordergroup
    @transaction  = transaction

    mail :to => user.email,
         :subject => "[#{FoodsoftConfig[:name]}] " + I18n.t('mailer.negative_balance')
  end

  def feedback(user, feedback)
    set_foodcoop_scope
    @user = user
    @feedback = feedback

    mail :to => FoodsoftConfig[:notification]["error_recipients"],
         :from => "#{user.nick} <#{user.email}>",
         :sender => FoodsoftConfig[:notification]["sender_address"],
         :errors_to => FoodsoftConfig[:notification]["sender_address"],
         :subject => "[#{FoodsoftConfig[:name]}] " + I18n.t('mailer.feedback.subject', :email => user.email)
  end

  def not_enough_users_assigned(task, user)
    set_foodcoop_scope
    @task = task
    @user = user

    mail :to => user.email,
         :subject => "[#{FoodsoftConfig[:name]}] " + I18n.t('mailer.not_enough_users_assigned.subject', :task => task.name)
  end

  private

  def set_foodcoop_scope(foodcoop = FoodsoftConfig.scope)
    ActionMailer::Base.default_url_options[:protocol] = FoodsoftConfig[:protocol]
    ActionMailer::Base.default_url_options[:host] = FoodsoftConfig[:host]
    ActionMailer::Base.default_url_options[:foodcoop] = foodcoop
  end
  
end
