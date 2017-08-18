# encoding: utf-8
# ActionMailer class that handles all emails for Foodsoft.
class Mailer < ActionMailer::Base
  # XXX Quick fix to allow the use of show_user. Proper take would be one of
  #     (1) Use draper, decorate user
  #     (2) Create a helper with this method, include here and in ApplicationHelper
  helper :application
  include ApplicationHelper

  layout 'email'  # Use views/layouts/email.txt.erb

  default from: "#{I18n.t('layouts.foodsoft')} <#{FoodsoftConfig[:email_sender]}>",
          'X-Auto-Response-Suppress' => 'All'

  # Sends an email with instructions on how to reset the password.
  # Assumes user.setResetPasswordToken has been successfully called already.
  def reset_password(user)
    @user = user
    @link = new_password_url(id: @user.id, token: @user.reset_password_token)

    mail to: user,
         subject: I18n.t('mailer.reset_password.subject', username: show_user(user))
  end

  # Sends an invite email.
  def invite(invite)
    @invite = invite
    @link = accept_invitation_url(token: @invite.token)

    mail to: invite.email,
         subject: I18n.t('mailer.invite.subject')
  end

  # Notify user of upcoming task.
  def upcoming_tasks(user, task)
    @user = user
    @task = task

    mail to: user,
         subject: I18n.t('mailer.upcoming_tasks.subject')
  end

  # Sends order result for specific Ordergroup
  def order_result(user, group_order)
    @order        = group_order.order
    @group_order  = group_order

    mail to: user,
         subject: I18n.t('mailer.order_result.subject', name: group_order.order.name)
  end

  # Notify user if account balance is less than zero
  def negative_balance(user,transaction)
    @group        = user.ordergroup
    @transaction  = transaction

    mail to: user,
         subject: I18n.t('mailer.negative_balance.subject')
  end

  def feedback(user, feedback)
    @user = user
    @feedback = feedback

    mail to: FoodsoftConfig[:notification][:error_recipients],
         from: user,
         subject: I18n.t('mailer.feedback.subject')
  end

  def not_enough_users_assigned(task, user)
    @task = task
    @user = user

    mail to: user,
         subject: I18n.t('mailer.not_enough_users_assigned.subject', task: task.name)
  end

  def mail(args)
    args[:message_id] = "#{Mail.random_tag}@#{default_url_options[:host]}" unless args[:message_id]
    args[:subject] = "[#{FoodsoftConfig[:name]}] #{args[:subject]}"

    if args[:from].is_a? User
      args[:reply_to] = args[:from] unless args[:reply_to]
      args[:from] = "#{show_user args[:from]} via #{I18n.t('layouts.foodsoft')} <#{FoodsoftConfig[:email_sender]}>"
    end

    [:bcc, :cc, :reply_to, :sender, :to].each do |k|
      user = args[k]
      args[k] = "#{show_user user} <#{user.email}>" if user.is_a? User
    end

    super
  end

  def self.deliver_now_with_user_locale(user, &block)
    I18n.with_locale(user.settings['profile']['language']) do
      self.deliver_now &block
    end
  end

  def self.deliver_now
    message = yield
    message.deliver_now
  rescue => error
    MailDeliveryStatus.create email: message.to[0], message: error.message
  end

end
