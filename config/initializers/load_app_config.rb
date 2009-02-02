raw_config = File.read(RAILS_ROOT + "/config/app_config.yml")
APP_CONFIG = YAML.load(raw_config)[RAILS_ENV].symbolize_keys


# Configuration of the exception_notification plugin
# Mailadresses are set in config/foodsoft.yaml
ExceptionNotifier.exception_recipients = APP_CONFIG[:notification]['error_recipients']
ExceptionNotifier.sender_address = APP_CONFIG[:notification]['sender_address']
ExceptionNotifier.email_prefix = APP_CONFIG[:notification]['email_prefix']