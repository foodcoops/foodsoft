class DeleteOrphanedRecordsFromAllTables < ActiveRecord::Migration
  class Article < ActiveRecord::Base; end
  class ArticleCategory < ActiveRecord::Base; end
  class ArticlePrice < ActiveRecord::Base; end
  class GroupOrder < ActiveRecord::Base; end
  class FinancialTransaction < ActiveRecord::Base; end
  class GroupOrderArticle < ActiveRecord::Base; end
  class GroupOrderArticleQuantity < ActiveRecord::Base; end
  class Invite < ActiveRecord::Base; end
  class Message < ActiveRecord::Base; end
  class Group < ActiveRecord::Base; end
  class MessageRecipient < ActiveRecord::Base; end
  class OrderArticle < ActiveRecord::Base; end
  class OrderComment < ActiveRecord::Base; end
  class Order < ActiveRecord::Base; end
  class Supplier < ActiveRecord::Base; end
  class Setting < ActiveRecord::Base; end

  def up
    Article.where.not(article_category_id: ArticleCategory.all).destroy_all
    ArticlePrice.where.not(article_id: Article.all).destroy_all
    GroupOrder.where.not(updated_by_user_id: User.all).update_all(updated_by_user_id: nil)
    FinancialTransaction.where.not(user_id: User.all).destroy_all
    GroupOrderArticle.where.not(order_article_id: OrderArticle.all).destroy_all
    Invite.where.not(user_id: User.all).destroy_all
    Message.where.not(sender_id: User.all).update_all(sender_id: nil)
    MessageRecipient.where.not(user_id: User.all).destroy_all
    Message.where.not(group_id: Group.all).update_all(group_id: nil)
    Message.where.not(id: MessageRecipient.all.map {|r| r.message_id}).destroy_all
    Message.where.not(reply_to: Message.all.map {|m| m.id}).update_all(reply_to: nil)
    MessageRecipient.where.not(message_id: Message.all).destroy_all
    GroupOrder.where.not(ordergroup_id: Group.all).destroy_all
    OrderArticle.where.not(article_id: Article.all).destroy_all
    GroupOrderArticle.where.not(group_order_id: GroupOrder.all).destroy_all
    GroupOrderArticle.where.not(order_article_id: OrderArticle.all).destroy_all
    GroupOrderArticleQuantity.where.not(group_order_article_id: GroupOrderArticle.all).destroy_all
    OrderComment.where.not(order_id: Order.all).destroy_all
    OrderComment.where.not(user_id: User.all).update_all(user_id: nil)
    Order.where.not(supplier_id: Supplier.all).update_all(supplier_id: nil)
    Order.where.not(updated_by_user_id: User.all).update_all(updated_by_user_id: nil)
    Order.where.not(created_by_user_id: User.all).update_all(created_by_user_id: nil)

    # We're not going to be able to add a FK constraint for settings, but still...:
    Setting.where(thing_type: 'User').where.not(thing_id: User.all).destroy_all
  end

  def down
    # irreversible
  end
end

