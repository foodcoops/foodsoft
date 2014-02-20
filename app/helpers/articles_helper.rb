module ArticlesHelper
  
  # useful for highlighting attributes, when synchronizing articles
  def highlight_new(unequal_attributes, attribute)
    unequal_attributes.detect {|a| a == attribute} ? "background-color: yellow" : ""
  end

  def row_classes(article)
    classes = []
    classes << "unavailable" if !article.availability
    classes << "just-updated" if article.recently_updated && article.availability
    classes.join(" ")
  end

  # Flatten search params, used in import from external database
  def search_params
    Hash[params[:q].map { |k,v| [k, (v.is_a?(Array) ? v.join(" ") : v)] }]
  end
end
