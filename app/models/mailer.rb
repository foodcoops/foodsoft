# ActionMailer class that handles all emails for the FoodSoft.
class Mailer < ActionMailer::Base

  layout 'email'  # Use views/layouts/email.html.erb
  
  # Sends an email copy of the given internal foodsoft message.
  def message(message, recipient)
    headers     'Sender' => Foodsoft.config[:email_sender], 'Errors-To' => Foodsoft.config[:email_sender]
    subject     "[#{Foodsoft.config[:name]}] " + message.subject
    recipients  recipient.email
    from        "#{message.sender.nick} <#{message.sender.email}>"
    body        :body         => message.body,
                :sender       => message.sender.nick,
                :recipients   => recipient.nick,
                :reply        => "#{Foodsoft.config[:base_url]}/messages/reply/#{message.id}",
                :link         => "#{Foodsoft.config[:base_url]}/messages/show/#{message.id}",
                :profile      => "#{Foodsoft.config[:base_url]}/home/profile"
  end

  # Sends an email with instructions on how to reset the password.
  # Assumes user.setResetPasswordToken has been successfully called already.
  def reset_password(user)
    prepare_system_message(user)
    subject     "[#{Foodsoft.config[:name]}] Neues Passwort für/ New password for #{user.nick}"
    body        :user => user,
                :link => "#{Foodsoft.config[:base_url]}/login/password/#{user.id}?token=#{user.reset_password_token}"
  end
    
  # Sends an invite email.
  def invite(invite)
    prepare_system_message(invite)
    subject     "Einladung in die Foodcoop #{Foodsoft.config[:name]} - Invitation to the Foodcoop"
    body        :invite => invite,
                :link   => "#{Foodsoft.config[:base_url]}/login/invite/#{invite.token}"
  end

  # Notify user of upcoming task.
  def upcoming_tasks(user, task)
    prepare_system_message(user)
    subject   "[#{Foodsoft.config[:name]}] Aufgaben werden fällig!"
    body        :user => user,
                :task => task
  end

  # Sends order result for specific Ordergroup
  def order_result(user, group_order)
    prepare_system_message(user)
    subject   "[#{Foodsoft.config[:name]}] Bestellung beendet: #{group_order.order.name}"
    body      :order        => group_order.order,
              :group_order  => group_order
  end

  # Notify user if account balance is less than zero
  def negative_balance(user,transaction)
    prepare_system_message(user)
    subject   "[#{Foodsoft.config[:name]}] Gruppenkonto im Minus"
    body      :group        => user.ordergroup,
              :transaction  => transaction
  end

  protected

  def prepare_system_message(recipient)
    recipients  recipient.email
    from        "FoodSoft <#{Foodsoft.config[:email_sender]}>"
  end
  
end
