module Finance::BalancingHelper
  def balancing_view_partial
    view = params[:view] || 'edit_results'
    case view
    when 'edit_results'
      'edit_results_by_articles'
    when 'groups_overview'
      'shared/articles_by/groups'
    when 'articles_overview'
      'shared/articles_by/articles'
    end
  end
end
