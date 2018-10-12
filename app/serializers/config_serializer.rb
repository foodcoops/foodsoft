class ConfigSerializer < ActiveModel::Serializer
  attributes :name, :homepage, :contact,
             :price_markup, :default_locale, :currency_unit, :currency_space,
             :use_tolerance, :tolerance_is_costly, :use_apple_points,
             :help_url, :applepear_url, :page_footer_html, :foodsoft

  def foodsoft
    {
      version: Foodsoft::VERSION,
      revision: Foodsoft::REVISION,
      url: object[:foodsoft_url]
    }
  end

  def page_footer_html
    # also see footer layout
    if FoodsoftConfig[:page_footer].present?
      FoodsoftConfig[:page_footer]
    elsif FoodsoftConfig[:homepage].present?
      ActionController::Base.helpers.link_to(FoodsoftConfig[:name], FoodsoftConfig[:homepage])
    else
      FoodsoftConfig[:name]
    end
  end
end
