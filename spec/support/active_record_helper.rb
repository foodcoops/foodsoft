module ActiveRecordHelper
  def clone_supplier_articles(from_supplier, to_supplier)
    from_supplier.articles.each do |article|
      article_duplicate = article.duplicate_including_latest_version_and_ratios
      article_duplicate.supplier_id = to_supplier.id

      article = Article.create(supplier_id: to_supplier.id)
      article.attributes = { latest_article_version_attributes: article_duplicate.latest_article_version.attributes.merge(article_unit_ratios_attributes: article_duplicate.latest_article_version.article_unit_ratios.map(&:attributes)) }
      article.save

      # act as if the article always looked that way:
      article.update(created_at: 1.year.ago, updated_at: 1.year.ago)
    end
  end
end

RSpec.configure do |config|
  config.include ActiveRecordHelper
end
