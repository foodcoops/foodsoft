# remove all currency translations, so that we can set the default language and
# have it shown in all other languages too
I18n.available_locales.each do |locale|
  unless locale == I18n.default_locale
    I18n.backend.store_translations(locale, number: { currency: { format: { unit: nil } } })
  end
end
