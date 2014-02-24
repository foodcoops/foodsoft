module OrderArticlesHelper

  def article_label_with_unit(article)
    pkg_info = pkg_helper(article, plain: true)
    "#{article.name} (#{[article.unit, pkg_info].reject(&:blank?).join(' ')})"
  end

end
