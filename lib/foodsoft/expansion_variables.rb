module Foodsoft
  # Variable expansions for user-specified texts.
  #
  # This is used in wiki-pages and the footer, for example, to allow foodcoops
  # to show dynamic information in the text.
  #
  # Plugins can modify the variables by means of the `#variables` accessor.
  # Please be thoughful when choosing names as to avoid collisions.
  # Do not put non-public info in variables.
  module ExpansionVariables
    ACTIVE_MONTHS = 3

    # @return [Hash] Variables and their values
    cattr_accessor :variables

    # Hash of variables. Note that keys are Strings.
    @@variables = {
      'scope' => -> { FoodsoftConfig.scope },
      'name' => -> { FoodsoftConfig[:name] },
      'contact.street' => -> { FoodsoftConfig[:contact][:street] },
      'contact.zip_code' => -> { FoodsoftConfig[:contact][:zip_code] },
      'contact.city' => -> { FoodsoftConfig[:contact][:city] },
      'contact.country' => -> { FoodsoftConfig[:contact][:country] },
      'contact.email' => -> { FoodsoftConfig[:contact][:email] },
      'contact.phone' => -> { FoodsoftConfig[:contact][:phone] },
      'price_markup' => -> { FoodsoftConfig[:price_markup] },
      'homepage' => -> { FoodsoftConfig[:homepage] },

      'help_url' => -> { FoodsoftConfig[:help_url] },
      'applepear_url' => -> { FoodsoftConfig[:applepear_url] },

      'foodsoft.url' => -> { FoodsoftConfig[:foodsoft_url] },
      'foodsoft.version' => Foodsoft::VERSION,
      'foodsoft.revision' => Foodsoft::REVISION,

      'user_count' => -> { User.undeleted.count },
      'ordergroup_count' => -> { Ordergroup.undeleted.count },
      'active_ordergroup_count' => -> { active_ordergroup_count },
      'supplier_count' => -> { Supplier.undeleted.count },
      'active_supplier_count' => -> { active_supplier_count },
      'active_suppliers' => -> { active_suppliers },
      'first_order_date' => -> { I18n.l Order.first.try { |o| o.starts.to_date } }
    }

    # Return expanded variable
    # @return [String] Expanded variable
    def self.get(var)
      s = @@variables[var.to_s]
      s.respond_to?(:call) ? s.call : s.to_s
    end

    # Expand variables in a string
    # @param str [String] String to expand variables in
    # @param options [Hash<String, String>] Extra variables to expand
    # @return [String] Expanded string
    def self.expand(str, options = {})
      str.gsub /{{([._a-zA-Z0-9]+)}}/ do
        options[$1] || self.get($1)
      end
    end

    # @return [Number] Number of ordergroups that have been active in the past 3 months
    def self.active_ordergroup_count
      GroupOrder
        .where('updated_on > ?', ACTIVE_MONTHS.months.ago)
        .select(:ordergroup_id).distinct.count
    end

    # @return [Number] Number of suppliers that has been ordered from in the past 3 months
    def self.active_supplier_count
      Order
        .where('starts > ?', ACTIVE_MONTHS.months.ago)
        .select(:supplier_id).distinct.count
    end

    # @return [String] Comma-separated list of suppliers that has been ordered from in the past 3 months
    def self.active_suppliers
      Supplier.joins(:orders)
              .where('orders.starts > ?', ACTIVE_MONTHS.months.ago)
              .order(:name).select(:name).distinct
              .map(&:name).join(', ')
    end
  end
end
