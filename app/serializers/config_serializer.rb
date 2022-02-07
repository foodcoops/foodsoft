class ConfigSerializer < ActiveModel::Serializer
  # details
  attributes :name, :homepage, :contact

  # settings
  attributes :currency_unit, :currency_space, :default_locale, :price_markup,
             :tolerance_is_costly, :distribution_strategy, :use_apple_points, :use_tolerance

  # layout
  attributes :page_footer_html, :webstats_tracking_code_html

  # help and version
  attributes :applepear_url, :help_url, :foodsoft

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

  def webstats_tracking_code_html
    FoodsoftConfig[:webstats_tracking_code].presence
  end
end
