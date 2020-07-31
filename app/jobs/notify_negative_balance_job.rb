class NotifyNegativeBalanceJob < ApplicationJob
  def execute(ordergroup, transaction)
    ordergroup.users.each do |user|
      next unless user.settings.notify['negative_balance']
      Mailer.deliver_now_with_user_locale user do
        Mailer.negative_balance(user, transaction)
      end
    end
  end
end
