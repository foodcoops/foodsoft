module ArticlesHelper
  # useful for highlighting attributes, when synchronizing articles
  def highlight_new(unequal_attributes, attribute)
    return unless unequal_attributes

    unequal_attributes.has_key?(attribute) ? "background-color: yellow" : ""
  end

  def row_classes(article)
    classes = []
    classes << "unavailable" if !article.availability
    classes << "just-updated" if article.recently_updated && article.availability
    classes.join(" ")
  end
end
