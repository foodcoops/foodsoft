module Pickup
  # What an ordergroup ordered of an article, and what it will receive.
  #
  # The quantities are those of the GroupOrderArticle; name, unit and deposit
  # come from the ArticleVersion of the order rather than from the current
  # Article, so an app shows what the order was actually made at and not what
  # the article costs today.
  class GroupOrderArticleSerializer < ActiveModel::Serializer
    attributes :id, :order_article_id, :article_id, :name, :unit, :deposit, :ordered, :tolerance, :received

    def article_id
      object.order_article.article_version.article_id
    end

    def name
      object.order_article.article_version.name
    end

    def unit
      object.order_article.article_version.unit
    end

    def deposit
      object.order_article.article_version.deposit.to_f
    end

    def ordered
      object.quantity
    end

    def received
      object.result
    end
  end
end
