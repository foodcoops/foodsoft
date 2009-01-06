# Remove this file, when every gettext-method <_("text to translate..")>
# is replaced by rails L18n method: L18n.name.name...

module ActionView
  class Base
    def _(text)
      text
    end
  end
end

module ActiveRecord
  class Base
    def _(text)
      text
    end
  end
end