class MigrateUserSettings < ActiveRecord::Migration
  def up
    old_settings = ConfigurableSetting.all
    
    old_settings.each do |old_setting|
      # get target (user)
      type      = old_setting.configurable_type
      id        = old_setting.configurable_id
      user      = type.constantize.find(id)
      
      # get the data (settings)
      name      = old_setting.name
      namespace = name.split('.')[0]
      key       = name.split('.')[1].underscore # Camelcase to underscore
      
      # prepare value
      value     = YAML.load(old_setting.value)
      value     = value.nil? ? false : value
      
      # set the settings_attributes (thanks to settings.merge! we can set them one by one)
      user.settings_attributes = {
        "#{namespace}" => {
          "#{key}" => value
        }
      }
      
      # save the user to apply after_save callback
      user.save
    end
  end

  def down
  end
end
