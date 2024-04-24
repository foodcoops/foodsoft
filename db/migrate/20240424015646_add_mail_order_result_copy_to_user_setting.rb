class AddMailOrderResultCopyToUserSetting < ActiveRecord::Migration[7.0]
  def up
    FoodsoftConfig[:mail_order_result_copy_to_user] = FoodsoftConfig::MailOrderResultCopyToUser::CC
  end

  def down
    FoodsoftConfig[:mail_order_result_copy_to_user] = nil
    FoodsoftConfig[:order_result_email_reply_to] = nil
    FoodsoftConfig[:order_result_email_reply_copy_to_user] = nil
  end
end
