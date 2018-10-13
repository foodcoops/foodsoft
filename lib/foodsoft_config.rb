# encoding: utf-8
#
# Foodcoop-specific configuration.
#
# This is loaded from +config/app_config.yml+, which contains a root
# key for each environment (plus an optional +defaults+ key). When using
# the multicoops feature (+multicoops+ is set to +true+ for the environment),
# each foodcoop has its own key.
#
# In addition to the configuration file, values can be overridden in the database
# using {RailsSettings::CachedSettings} as +foodcoop.<foodcoop_scope>.**+.
#
# Some values may not be set in the database (e.g. the database connection to
# sharedlists, or +default_scope+), these are defined as children of the
# +protected+ key. The default contains a sensible list, but you can modify
# that. Here's an almost minimal example:
#
#     default:
#       default_scope: f
#       host: order.foodstuff.test      # hostname for urls in emails
#
#       name: Fairy Foodstuff           # the name of our foodcoop
#       contact:
#         # ...
#         email: fairy@foodstuff.test   # general contact email address
#
#       price_markup: 6                 # foodcoop margin
#
#       protected:
#         shared_lists: false           # allow database connection override
#         use_messages: true            # foodcoops can't disable the use of messages
#
# When you like to whitelist protected attributes, define an entry +all: true+,
# then you can whitelist specific attributes setting them to +false+.
#
class FoodsoftConfig

  # @!attribute scope
  #   Returns the current foodcoop scope for the multicoops feature, otherwise
  #   the value of the foodcoop configuration key +default_scope+ is used.
  #   @return [String] The current foodcoop scope.
  mattr_accessor :scope
  # @!attribute config
  #   Returns a {ActiveSupport::HashWithIndifferentAccess Hash} with the current
  #   scope's configuration from the configuration file. Note that this does not
  #   include values that were changed in the database.
  #   @return [ActiveSupport::HashWithIndifferentAccess] Current configuration from configuration file.
  mattr_accessor :config

  # Configuration file location.
  #   Taken from environment variable +FOODSOFT_APP_CONFIG+,
  #   or else +config/app_config.yml+.
  APP_CONFIG_FILE = ENV['FOODSOFT_APP_CONFIG'] || 'config/app_config.yml'
  # Loaded configuration
  APP_CONFIG = ActiveSupport::HashWithIndifferentAccess.new

  class << self

    # Load and initialize foodcoop configuration file.
    # @param filename [String] Override configuration file
    def init(filename = APP_CONFIG_FILE)
      Rails.logger.info "Loading app configuration from #{APP_CONFIG_FILE}"
      APP_CONFIG.clear.merge! YAML.load(ERB.new(File.read(File.expand_path(filename, Rails.root))).result)
      # Gather program-default configuration
      self.default_config = get_default_config
      # Load initial config from development or production
      set_config Rails.env
      # Overwrite scope to have a better namescope than 'production'
      self.scope = config[:default_scope] or raise "No default_scope is set"
      # Set defaults for backward-compatibility
      set_missing
    end

    # Set config and database connection for specific foodcoop.
    #
    # Only needed in multi coop mode.
    # @param foodcoop [String, Symbol] Foodcoop to select.
    def select_foodcoop(foodcoop)
      set_config foodcoop
      setup_database
      setup_mailing
    end

    def select_default_foodcoop
      select_foodcoop config[:default_scope]
    end

    def select_multifoodcoop(foodcoop)
      select_foodcoop foodcoop if config[:multi_coop_install]
    end

    # Return configuration value for the currently selected foodcoop.
    #
    # First tries to read configuration from the database (cached),
    # then from the configuration files.
    #
    #     FoodsoftConfig[:name] # => 'FC Test'
    #
    # To avoid errors when the database is not yet setup (when loading
    # the initial database schema), cached settings are only being read
    # when the settings table exists.
    #
    # @param key [String, Symbol]
    # @return [Object] Value of the key.
    def [](key)
      if RailsSettings::CachedSettings.table_exists? && allowed_key?(key)
        value = RailsSettings::CachedSettings["foodcoop.#{self.scope}.#{key}"]
        value = config[key] if value.nil?
        value
      else
        config[key]
      end
    end

    # Store configuration in the database.
    #
    # If value is equal to what's defined in the configuration file, remove key from the database.
    # @param key [String, Symbol] Key
    # @param value [Object] Value
    # @return [Boolean] Whether storing succeeded (fails when key is not allowed to be set in database).
    def []=(key, value)
      return false unless allowed_key?(key)
      value = normalize_value value
      # then update database
      if config[key] == value || (config[key].nil? && value == false)
        # delete (ok if it was already deleted)
        begin
          RailsSettings::CachedSettings.destroy "foodcoop.#{self.scope}.#{key}"
        rescue RailsSettings::Settings::SettingNotFound
        end
      else
        # or store
        RailsSettings::CachedSettings["foodcoop.#{self.scope}.#{key}"] = value
      end
      return true
    end

    # @return [Array<String>] Configuration keys that are set (either in +app_config.yml+ or database).
    def keys
      keys = RailsSettings::CachedSettings.get_all("foodcoop.#{self.scope}.").try(:keys) || []
      keys.map! {|k| k.gsub /^foodcoop\.#{self.scope}\./, ''}
      keys += config.keys
      keys.map(&:to_s).uniq
    end

    # @return [Array<String>] Valid names of foodcoops.
    def foodcoops
      if config[:multi_coop_install]
        APP_CONFIG.keys.reject { |coop| coop =~ /^(default|development|test|production)$/ }
      else
        [config[:default_scope]]
      end
    end

    # Loop through each foodcoop and executes the given block after setup config and database
    def each_coop
      foodcoops.each do |coop|
        select_multifoodcoop coop
        yield coop
      end
    end

    def allowed_foodcoop?(foodcoop)
      foodcoops.include? foodcoop
    end

    # @return [Boolean] Whether this key may be set in the database
    def allowed_key?(key)
      # fast check for keys without nesting
      if self.config[:protected].include? key
        return !self.config[:protected][key]
      else
        return !self.config[:protected][:all]
      end
      # @todo allow to check nested keys as well
    end

    # @return [Hash] Full configuration.
    def to_hash
      Hash[keys.map {|k| [k, self[k]]} ]
    end

    # for using active_model_serializer in the api/v1/configs controller
    alias :read_attribute_for_serialization :[]

    protected

    # @!attribute default_config
    #   Returns the program-default foodcoop configuration.
    #
    #   Plugins (engines in Rails terms) can easily add to the default
    #   configuration by defining a method +default_foodsoft_config+ in
    #   their engine and modify the {Hash} passed.
    #
    #   When modifying this, please make sure to use default values that
    #   match old behaviour. For example, when the wiki was made optional
    #   and turned into a plugin, the configuration item +use_wiki+ was
    #   introduced with a default value of +true+ (set in the wiki plugin):
    #
    #      module FoodsoftWiki
    #         class Engine < ::Rails::Engine
    #           def default_foodsoft_config(cfg)
    #             cfg[:use_wiki] = true # keep backward compatibility
    #           end
    #         end
    #       end
    #
    #   @return [Hash] Default configuration values
    mattr_accessor :default_config


    private

    def set_config(foodcoop)
      raise "No config for this environment (#{foodcoop}) available!" if APP_CONFIG[foodcoop].nil?
      self.config = APP_CONFIG[foodcoop]
      self.scope = foodcoop
      set_missing
    end

    def setup_database
      database_config = ActiveRecord::Base.configurations[Rails.env]
      database_config = database_config.merge(config[:database]) if config[:database].present?
      ActiveRecord::Base.establish_connection(database_config)
    end

    def setup_mailing
      [:protocol, :host, :port, :script_name].each do |k|
        ActionMailer::Base.default_url_options[k] = self[k] if self[k]
      end
      ActionMailer::Base.default_url_options[:foodcoop] = scope
    end

    # Completes foodcoop configuration with program defaults.
    # @see #foodsoft_config
    def set_missing
      config.replace(default_config.deep_merge(config))
    end

    # Returns program-default configuration.
    #   When new options are introduced, put backward-compatible defaults here, so that
    #   configuration files that haven't been updated, still work as they did. This also
    #   makes sure that the configuration editor picks up the defaults.
    # @return [Hash] Program-default foodcoop configuration.
    # @see #default_config
    # @see #set_missing
    def get_default_config
      cfg = {
        use_nick: true,
        use_apple_points: true,
        # English is the default language, and this makes it show up as default.
        default_locale: 'en',
        currency_unit: '€',
        currency_space: true,
        foodsoft_url: 'https://github.com/foodcoops/foodsoft',
        contact: {}, # avoid errors when undefined
        tasks_period_days: 7,
        tasks_upfront_days: 49,
        # The following keys cannot, by default, be set by foodcoops themselves.
        protected: {
          multi_coop_install: true,
          default_scope: true,
          notification: true,
          shared_lists: true,
          protected: true,
          database: true
        }
      }
      # allow engines to easily add to this
      engines = Rails::Engine.subclasses.map(&:instance).select { |e| e.respond_to?(:default_foodsoft_config) }
      engines.each { |e| e.default_foodsoft_config(cfg) }
      cfg
    end

    # Normalize value recursively (which can be entered as strings, but we want to store it properly)
    def normalize_value(value)
      value = value.map{|v| normalize_value(v)} if value.is_a? Array
      if value.is_a? Hash
        value = ActiveSupport::HashWithIndifferentAccess[ value.to_a.map{|a| [a[0], normalize_value(a[1])]} ]
      end
      case value
        when 'true' then true
        when 'false' then false
        when /^[-+0-9]+$/ then value.to_i
        when /^[-+0-9.]+([eE][-+0-9]+)?$/ then value.to_f
        when '' then nil
        else value
      end
    end


  end
end
