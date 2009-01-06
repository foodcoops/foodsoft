# Remove this file, when every gettext-method <_("text to translate..")>
# is replaced by rails l18n method: l18n.name.name...

module ActionView
  class Base
    def _(text)
      text
    end
  end
end