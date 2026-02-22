# ActionMailer class that handles all emails for Foodsoft.
class Mailer < ActionMailer::Base
  # XXX Quick fix to allow the use of show_user. Proper take would be one of
  #     (1) Use draper, decorate user
  #     (2) Create a helper with this method, include here and in ApplicationHelper
  helper :application
  include ApplicationHelper

  helper :articles
  include ArticlesHelper

  layout 'email' # Use views/layouts/email.txt.erb

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
    @next_tasks = Task.order(:due_date).next_assigned_tasks_for(user)

    mail to: user,
         subject: I18n.t('mailer.upcoming_tasks.subject')
  end

  # Sends a welcome email with instructions on how to reset the password.
  # Assumes user.setResetPasswordToken has been successfully called already.
  def welcome(user)
    @user = user
    @additional_text = additonal_welcome_text(user)
    @link = new_password_url(id: @user.id, token: @user.reset_password_token)

    mail to: user,
         subject: I18n.t('mailer.welcome.subject')
  end

  # Sends order result for specific Ordergroup
  def order_result(user, group_order)
    @order        = group_order.order
    @group_order  = group_order

    mail to: user,
         subject: I18n.t('mailer.order_result.subject', name: group_order.order.name)
  end

  # Sends order received info for specific Ordergroup
  def order_received(user, group_order)
    @order        = group_order.order
    @group_order  = group_order

    order_articles = @order.order_articles.reject { |oa| oa.units_received.nil? }
    @abundant_articles = order_articles.select { |oa| oa.difference_received_ordered.positive? }
    @scarce_articles = order_articles.select { |oa| oa.difference_received_ordered.negative? }

    mail to: user,
         subject: I18n.t('mailer.order_received.subject', name: group_order.order.name)
  end

  # Sends order result to the supplier
  def order_result_supplier(user, order, options = {})
    @user     = user
    @order    = order
    @supplier = order.supplier

    add_order_result_attachments order, options

    subject = I18n.t('mailer.order_result_supplier.subject', name: order.supplier.name)
    subject += " (#{I18n.t('activerecord.attributes.order.pickup')}: #{format_date(order.pickup)})" if order.pickup

    mail to: order.supplier.email,
         cc: user,
         reply_to: user,
         subject: subject
  end

  # Notify user if account balance is less than zero
  def negative_balance(user, transaction)
    @group        = user.ordergroup
    @transaction  = transaction

    mail to: user,
         subject: I18n.t('mailer.negative_balance.subject')
  end

  def not_enough_users_assigned(task, user)
    @task = task
    @user = user

    mail to: user,
         subject: I18n.t('mailer.not_enough_users_assigned.subject', task: task.name)
  end

  def mail(args)
    args[:message_id] ||= "<#{Mail.random_tag}@#{default_url_options[:host]}>"
    args[:subject] = "[#{FoodsoftConfig[:name]}] #{args[:subject]}"

    if args[:from].is_a? User
      args[:reply_to] ||= args[:from]
      args[:from] =
        format_address(FoodsoftConfig[:email_sender], I18n.t('mailer.from_via_foodsoft', name: show_user(args[:from])))
    end

    %i[bcc cc reply_to sender to].each do |k|
      user = args[k]
      args[k] = format_address(user.email, show_user(user)) if user.is_a? User
    end

    if contact_email = FoodsoftConfig[:contact][:email]
      args[:reply_to] ||= format_address(contact_email, FoodsoftConfig[:name])
    end

    reply_email_domain = FoodsoftConfig[:reply_email_domain]
    if reply_email_domain && !args[:return_path] && args[:to].is_a?(String)
      address = Mail::Parsers::AddressListsParser.parse(args[:to]).addresses.first
      args[:return_path] = "<#{FoodsoftConfig.scope}.bounce+#{address.local}=#{address.domain}@#{reply_email_domain}>"
    end

    super
  end

  def self.deliver_now_with_user_locale(user, &block)
    I18n.with_locale(user.settings['profile']['language']) do
      deliver_now(&block)
    end
  end

  def self.deliver_now_with_default_locale(&block)
    I18n.with_locale(FoodsoftConfig[:default_locale]) do
      deliver_now(&block)
    end
  end

  def self.deliver_now
    message = yield
    message.deliver_now
  rescue StandardError => e
    MailDeliveryStatus.create email: message.to[0], message: e.message
  end

  # separate method to allow plugins to mess with the attachments
  def add_order_result_attachments(order, options = {})
    attachments['order.pdf'] = OrderFax.new(order, options).to_pdf
    attachments['order.csv'] = OrderCsv.new(order, options).to_csv
  end

  # separate method to allow plugins to mess with the text
  def additonal_welcome_text(user); end

  private

  def format_address(email, name)
    address = Mail::Address.new email
    address.display_name = name
    address.format
  end
end
