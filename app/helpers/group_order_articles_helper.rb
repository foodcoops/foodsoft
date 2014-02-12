module GroupOrderArticlesHelper

  # return an edit field for a GroupOrderArticle result
  def group_order_article_edit_result(goa)
    unless goa.group_order.order.finished? and current_user.role_finance?
      goa.result
    else
      simple_form_for goa, remote: true, html: {'data-submit-onchange' => 'changed', class: 'delta-input'} do |f|
        f.input_field :result, as: :delta, class: 'input-nano', data: {min: 0}, id: "r_#{goa.id}"
      end
    end
  end

end
