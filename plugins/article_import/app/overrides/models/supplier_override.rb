Supplier.class_eval do
    # Synchronise articles with spreadsheet.
  #
  # @param file [File] Spreadsheet file to parse
  # @param options [Hash] Options passed to {FoodsoftArticleImport#parse} except when listed here.
  # @option options [Boolean] :outlist_absent Set to +true+ to remove articles not in spreadsheet.
  # @option options [Boolean] :convert_units Omit or set to +true+ to keep current units, recomputing unit quantity and price.
  def sync_from_file(file, type, options = {})
    all_order_numbers = []
    updated_article_pairs, outlisted_articles, new_articles = [], [], []
    custom_codes_path = File.join(Rails.root, "config", "custom_codes.yml")
    opts = options.except(:convert_units, :outlist_absent)
    custom_codes_file_path = custom_codes_path if File.exist?(custom_codes_path)
    FoodsoftArticleImport.parse(file, custom_file_path: custom_codes_file_path, type: type, **opts) do |new_attrs, status, line|
      article = articles.undeleted.where(order_number: new_attrs[:order_number]).first

      if new_attrs[:article_category].present? && options[:update_category]
        new_attrs[:article_category] = ArticleCategory.find_match(new_attrs[:article_category]) || ArticleCategory.create_or_find_by!(name: new_attrs[:article_category])
      else
        new_attrs[:article_category] = nil
      end

      new_attrs[:tax] ||= FoodsoftConfig[:tax_default]
      new_article = articles.build(new_attrs)
      if status.nil?
        if article.nil?
          new_articles << new_article
        else
          unequal_attributes = article.unequal_attributes(new_article, options.slice(:convert_units, :update_category))
          unless unequal_attributes.empty?
            article.attributes = unequal_attributes
            updated_article_pairs << [article, unequal_attributes]
          end
        end
      elsif status == :outlisted && article.present?
        outlisted_articles << article

      # stop when there is a parsing error
      elsif status.is_a? String
        # @todo move I18n key to model
        raise I18n.t('articles.model.error_parse', :msg => status, :line => line.to_s)
      end

      all_order_numbers << article.order_number if article
    end
    if options[:outlist_absent]
      outlisted_articles += articles.undeleted.where.not(order_number: all_order_numbers + [nil])
    end
    [updated_article_pairs, outlisted_articles, new_articles]
  end
end
