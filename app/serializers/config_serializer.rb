class ConfigSerializer < ActiveModel::Serializer
  attributes :name, :homepage, :contact,
             :price_markup, :default_locale, :currency_unit, :currency_space,
             :use_tolerance, :tolerance_is_costly, :use_apple_points,
             :help_url, :applepear_url, :foodsoft

  def foodsoft
    {
      version: Foodsoft::VERSION,
      revision: Foodsoft::REVISION,
      url: object[:foodsoft_url]
    }
  end
end
