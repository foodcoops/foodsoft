class MigrateUserSettings < ActiveRecord::Migration[4.2]
  def up
    say_with_time 'Save old user settings in new RailsSettings module' do
      # Allow setting default locale via env parameter
      # This is used, when setting users language settings
      default_locale = I18n.default_locale
      tmp_locale = ENV['DEFAULT_LOCALE'].present? ? ENV['DEFAULT_LOCALE'].to_sym : default_locale
      I18n.default_locale = tmp_locale

      old_settings = ConfigurableSetting.all

      old_settings.each do |old_setting|
        # get target (user)
        type      = old_setting.configurable_type
        id        = old_setting.configurable_id
        begin
          user = type.constantize.find(id)
        rescue ActiveRecord::RecordNotFound
          Rails.logger.debug { "Can't find configurable object with type: #{type.inspect}, id: #{id.inspect}" }
          next
        end

        # get the data (settings)
        name      = old_setting.name
        namespace = name.split('.')[0]
        key       = name.split('.')[1].underscore # Camelcase to underscore

        # prepare value
        value     = YAML.load(old_setting.value)
        value     = false if value.nil?

        # set the settings_attributes (thanks to settings.merge! we can set them one by one)
        user.settings_attributes = {
          "#{namespace}" => {
            "#{key}" => value
          }
        }

        # save the user to apply after_save callback
        user.save
      end

      I18n.default_locale = default_locale
    end

    drop_table :configurable_settings
  end

  def down
  end
end

# this is the base class of all configurable settings
class ConfigurableSetting < ActiveRecord::Base; end
