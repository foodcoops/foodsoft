module ArticlesHelper
  
  # useful for highlighting attributes, when synchronizing articles
  def highlight_new(unequal_attributes, attribute)
    unequal_attributes.detect {|a| a == attribute} ? "background-color: yellow" : ""
  end

  def row_classes(article)
    classes = ""
    classes += ' unavailable' if article.availability
    classes += " just_updated" if @article.recently_updated && @article.availability
    classes
  end
end