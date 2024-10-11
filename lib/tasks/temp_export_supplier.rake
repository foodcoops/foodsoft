namespace :temp_supplier do
  task export: :environment do
    supplier_id = ENV['SUPPLIER_ID']&.to_i
    raise 'Missing supplier id' if supplier_id.nil?

    s = Supplier.find_by_id(supplier_id)
    article_hashes = s.articles.map do |a|
      article_attributes = a.attributes.delete_if { |key| %w[quantity type deleted_at shared_updated_on].include?(key) }
      latest_version_attributes = a.latest_article_version.attributes.delete_if do |key|
        %w[article_id id].include?(key)
      end
      aur = a.article_unit_ratios.map do |ratio|
        attributes = ratio.attributes
        attributes.delete_if { |key| %w[id sort].include?(key) }
        attributes
      end

      cat = ArticleCategory.find_by_id(latest_version_attributes['article_category_id'])
      latest_version_attributes['article_category'] = cat.attributes.delete('id')
      latest_version_attributes.delete('article_category_id')

      article_attributes.merge(latest_version_attributes).merge(article_unit_ratios: aur)
    end

    puts JSON.pretty_generate({
                                api_version: 1,
                                data: {
                                  changed_after: Time.now,
                                  articles: article_hashes
                                }
                              })
  end
end
