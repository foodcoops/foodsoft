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
    Hash[params[:search].map { |k,v| [k, (v.is_a?(Array) ? v.join(" ") : v)] }]
  end

  # show icon with link to product information when available
  def article_info_icon(article)
    icon = "<i class='icon-info-sign'></i>".html_safe
    unless article.info_url.blank?
      link_to icon, article.info_url, target: '_blank'
    else
      icon
    end
  end

end
