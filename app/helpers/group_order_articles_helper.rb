module GroupOrderArticlesHelper
  # return an edit field for a GroupOrderArticle result
  def group_order_article_edit_result(goa, convert_to_billing_unit = true)
    result = number_with_precision goa.result, strip_insignificant_zeros: true

    if goa.group_order.order.finished? && current_user.role_finance? && !goa.new_record?
      order_article = goa.order_article
      article_version = order_article.article_version
      simple_form_for goa, remote: true, html: { 'data-submit-onchange' => 'changed', class: 'form-inline' } do |f|
        quantity_data = ratio_quantity_data(order_article, order_article.article_version.billing_unit)
        converted_value = if convert_to_billing_unit
                            article_version.convert_quantity(goa.result,
                                                             article_version.group_order_unit, article_version.billing_unit)
                          else
                            result
                          end
        input_data = { min: 0 }.merge(quantity_data)
        if convert_to_billing_unit
          input_data = input_data.merge('multiply-before-submit': article_version.convert_quantity(1,
                                                                                                   article_version.billing_unit, article_version.group_order_unit))
        end
        f.input_field(:result, as: :delta, class: 'form-control', data: input_data, id: "r_#{goa.id}",
                               value: format_number(converted_value, 3))
      end
    else
      return result unless can_be_edited_in_place?(goa)

      order_article = goa.order_article
      quantity_data = ratio_quantity_data(order_article, order_article.article_version.billing_unit)
      input_data = { min: 0 }.merge(quantity_data)
      simple_form_for goa, remote: true, html: { 'data-submit-onchange' => 'changed', class: 'form-inline' } do |f|
        fields_html = f.input_field :result, as: :delta, class: 'form-control', data: input_data, id: "r_#{goa.id || ('new_oa_' + order_article.id.to_s)}", value: result
        if goa.new_record?
          fields_html += f.hidden_field :order_article_id
          fields_html += f.hidden_field :group_order_id
          fields_html += f.hidden_field :quantity
          fields_html += f.hidden_field :tolerance
        end

        fields_html
      end
    end
  end

  private

  def can_be_edited_in_place?(goa)
    goa.group_order.order.finished? && (
      current_user.role_finance? ||
      (FoodsoftConfig[:use_self_service] && goa.group_order.ordergroup.member?(current_user))
    )
  end
end
