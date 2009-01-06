module ArticlesHelper
  
  # useful for highlighting attributes, when synchronizing articles
  def highlight_new(unequal_attributes, attribute)
    unequal_attributes.detect {|a| a == attribute} ? "background-color: yellow" : ""
  end
end