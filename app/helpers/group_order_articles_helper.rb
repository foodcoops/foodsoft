module GroupOrderArticlesHelper

  # return an edit field for a GroupOrderArticle result
  def group_order_article_edit_result(goa)
    unless goa.group_order.order.finished? && current_user.role_finance?
      goa.result
    else
      simple_form_for goa, remote: true, html: {'data-submit-onchange' => 'changed', class: 'delta-input'} do |f|
        f.input_field :result, as: :delta, class: 'input-nano', data: {min: 0}, id: "r_#{goa.id}"
      end
    end
  end

  def group_order_article_show_result(goa)
    goa.result
  end

  def group_order_article_edit_amount(goa)
    unit = goa.order_article.article.unit
    fc_unit = (::Unit.new(unit) rescue nil) || (::Unit.new(unit.downcase) rescue nil)
    if fc_unit.nil?
      goa.result
    else
      content_tag(:div, class: 'input-append') do
        concat text_field_tag("a_#{goa.id}", (goa.result * fc_unit.scalar),
                              class: 'input-nano',
                              onkeyup: "updateReceived('#{goa.id}', #{fc_unit.scalar});",
               style: 'text-align:right;')
        concat content_tag(:span, fc_unit.units, class: 'add-on')
      end
    end
  end

  def group_order_article_show_amount(goa)
    unit = goa.order_article.article.unit
    fc_unit = (::Unit.new(unit) rescue nil) || (::Unit.new(unit.downcase) rescue nil)
    if fc_unit.nil?
      goa.result
    else
      goa.result * fc_unit
    end
  end

  def group_order_article_total_amount(total, order_article)
    unit = order_article.article.unit
    fc_unit = (::Unit.new(unit) rescue nil) || (::Unit.new(unit.downcase) rescue nil)
    if fc_unit.nil?
      total
    else
      total * fc_unit
    end
  end


end
