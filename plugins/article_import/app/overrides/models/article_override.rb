Article.class_eval do
  def unequal_attributes(new_article, options = {})
    # try to convert different units when desired
    if options[:convert_units] == false
      new_price = nil
      new_unit_quantity = nil
    else
      new_price, new_unit_quantity = convert_units(new_article)
    end
    if new_price && new_unit_quantity
      new_unit = self.unit
    else
      new_price = new_article.price
      new_unit_quantity = new_article.unit_quantity
      new_unit = new_article.unit
    end

    attribute_hash = {
      :name => [self.name, new_article.name],
      :manufacturer => [self.manufacturer, new_article.manufacturer.to_s],
      :origin => [self.origin, new_article.origin],
      :unit => [self.unit, new_unit],
      :price => [self.price.to_f.round(2), new_price.to_f.round(2)],
      :tax => [self.tax, new_article.tax],
      :deposit => [self.deposit.to_f.round(2), new_article.deposit.to_f.round(2)],
      # take care of different num-objects.
      :unit_quantity => [self.unit_quantity.to_s.to_f, new_unit_quantity.to_s.to_f],
      :note => [self.note.to_s, new_article.note.to_s]
    }
    if options[:update_category] == true
      new_article_category = new_article.article_category
      attribute_hash[:article_category] = [self.article_category, new_article_category] unless new_article_category.blank?
    end

    Article.compare_attributes(attribute_hash)
  end
end
