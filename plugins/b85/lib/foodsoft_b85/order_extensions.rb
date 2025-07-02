module FoodsoftB85
  module OrderExtensions
    extend ActiveSupport::Concern

    included do
      validate :ftp_uploadable, if: -> { supplier&.remote_order_method == :ftp_b85 }

      def ftp_uploadable
        selected_articles = Article.find(article_ids)
        invalid_articles = selected_articles.reject do |article|
          order_article = order_articles.joins(:article_version).where(article_versions: { article_id: article.id }).first
          article_version = order_article&.article_version || article.latest_article_version
          # - all ordered articles must have an order number <= 13 digits
          # - the article must have at least one unit ratio (packaging quantity)
          # - the packaging quantity must be less than 10'000 (4 digits)
          # - the order quantity must be less than 10'000 (4 digits)
          article_version.order_number.present? &&
            article_version.order_number.length <= 13 &&
            article_version.article_unit_ratios.exists? &&
            article_version.article_unit_ratios.first.quantity <= 10_000 &&
            order_article&.units_to_order.to_i <= 10_000
        end
        @erroneous_article_ids ||= []
        @erroneous_article_ids += invalid_articles.map(&:id)
        errors.add(:articles, I18n.t('orders.model.error_not_ftp_uploadable')) unless invalid_articles.empty?
      end
    end
  end
end
