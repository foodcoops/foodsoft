module ArticlesHelper
  
  # useful for highlighting attributes, when synchronizing articles
  def highlight_new(unequal_attributes, attribute)
    return unless unequal_attributes
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
    return {} unless params[:q]
    Hash[params[:q].map { |k,v| [k, (v.is_a?(Array) ? v.join(" ") : v)] }]
  end

  # Input field with sync_skip_columns button
  def input_with_sync(form, attr)
    attr = attr.to_sym
    form.input attr do
      content_tag :div, class: 'input-append' do
        form.input_field(attr, disabled: !form.object.sync_skip_columns.include?(attr)) + \
        content_tag(:span, class: 'add-on') do
          form.input_field :sync_skip_columns, as: :check_boxes, collection: {'' => attr}
        end
      end
    end
  end
end
