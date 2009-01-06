require 'yaml'

# General FoodSoft module for application configuration and global methods.
# 
# This library needs to be loaded in environment.rb through <code>require 'foodsoft'</code>.
# 
module FoodSoft
  private 
  @@foodcoops = Hash.new
  @@database = Hash.new
  @@foodsoft = Hash.new
  @@subdomain = String.new
  
  public
  
  # Loads the configuration file config/foodsoft.yml, ..foodcoops.yml and ..database.yml
  def self.load_configuration
    # load foodcoops-config
    @@foodcoops = YAML::load(File.open("#{RAILS_ROOT}/config/foodcoops.yml"))
    
    # load database-config
    @@database = YAML::load(File.open("#{RAILS_ROOT}/config/database.yml"))
    
    # load foodsoft-config
    @@foodsoft = YAML::load(File.open("#{RAILS_ROOT}/config/foodsoft.yml")).symbolize_keys
    
    # validates the parsed data
    self.validate
    rescue => e
    # raise "Failed to load configuration files: #{e.message}" 
  end
  
  
  def self.subdomain=(subdomain)
    @@subdomain = subdomain
  end
  
  def self.subdomain
    return @@subdomain
  end
  
  def self.format_time(time = Time.now)
    raise "FoodSoft::time_format has not been set!" unless @@foodcoops[subdomain]["time_format"]
    time.strftime(@@foodcoops[subdomain]["time_format"]) unless time.nil?
  end
  
  def self.format_date(date = Time.now)
    raise "FoodSoft: date_format has not been set!" unless @@foodcoops[subdomain]["date_format"]
    date.strftime(@@foodcoops[subdomain]["date_format"]) unless date.nil?
  end
  
  def self.format_date_time(time = Time.now)
    "#{format_date(time)} #{format_time(time)}" unless time.nil?
  end
  
  def self.format_currency(decimal)
    "#{self.getCurrencyUnit} %01.2f" % decimal
  end
  
  # Returns the set host, otherwise returns nil
  def self.getHost
    return @@foodcoops[subdomain]["host"]
  end
  
  def self.getFoodcoopName
    raise 'foodcoopName has not been set!' unless @@foodcoops[subdomain]["name"] 
    return @@foodcoops[subdomain]["name"]
  end
  
  def self.getFoodcoopContact
    raise "contact has not been set!" unless @@foodcoops[subdomain]["contact"]
    return @@foodcoops[subdomain]["contact"].symbolize_keys
  end
  
  def self.getFoodcoopUrl
    return @@foodcoops[subdomain]["base_url"]
  end
  
  def self.getHelp
    raise 'foodsoftHelp has not been set!' unless @@foodcoops[subdomain]["help_url"]
    return @@foodcoops[subdomain]["help_url"]
  end
  
  # Returns the email sender used for system emails.
  def self.getEmailSender
    raise 'FoodSoft::emailSender has not been set!' unless @@foodcoops[subdomain]["email_sender"]
    return @@foodcoops[subdomain]["email_sender"]
  end
  
  # Returns the price markup.
  def self.getPriceMarkup
    raise "FoodSoft::priceMarkup has not been set!" unless @@foodcoops[subdomain]["price_markup"]
    return @@foodcoops[subdomain]["price_markup"]
  end
  
  # Returns the local decimal separator.
  def self.getDecimalSeparator
    if (separator = LocalizationSimplified::NumberHelper::CurrencyOptions[:separator])
      return separator
    else
      logger.warn('No locale configured through plugin LocalizationSimplified')
      return '.'
    end
  end
  
  # Returns the local currency unit.
  def self.getCurrencyUnit
    if (unit = LocalizationSimplified::NumberHelper::CurrencyOptions[:unit])
      return unit
    else
      logger.warn('No locale configured through plugin LocalizationSimplified')
      return '$'
    end
  end
  
  # Returns the delocalized version of the string, i.e. with the decimal separator local character properly replaced.
  # For example, for the locale "de-DE", the comma character "," will be replaced with the standard separator ".".
  def self.delocalizeDecimalString(string)
    if (string && string.is_a?(String) && !string.empty?)
      separator = getDecimalSeparator
      if (separator != '.' && string.index(separator))
        string = string.sub(separator, '.')
      end      
    end
    return string
  end
  
  # Return the specific database
  def self.get_database
    raise 'databse for foodcoop has not been set' unless @@database[subdomain]
    return @@database[subdomain]
  end
  
  # Foodsoft-Config begins

  # Returns an array with mail-adresses for the exception_notification plugin
  def self.get_notification_config
    raise 'FoodSoft::errorRecipients has not been set!' unless @@foodsoft[:notification]
    return @@foodsoft[:notification].symbolize_keys
  end
  
  # returns shared_lists database connection
  def self.get_shared_lists_config
    raise "sharedLists database config has not been set" unless @@foodsoft[:shared_lists]
    return @@foodsoft[:shared_lists]
  end
  
  # returns a string for an integrity hash for cookie session data
  def self.get_session_secret
    raise "session secret string has not been set" unless @@foodsoft[:session_secret]
    return @@foodsoft[:session_secret]
  end
  
  # returns units-hash for automatic units-conversion
  # this hash looks like {"KG" => 1, "500g" => 0.5, ...}
  def self.get_units_factors
    raise "units has not been set" unless @@foodsoft[:units]
    @@foodsoft[:units]
  end
  
  # validates the yaml-parsed-config-file
  def self.validate
    raise "Price markup is not a proper float. please use at least one decimal place" unless @@foodcoops.each {|fc| fc["price_markup"].is_a?(Float)}
    raise "Error recipients aren't set correctly. use hyphen for each recipient" unless @@foodsoft[:error_recipients].is_a?(Array)
  end
end

# Automatically load configuration file:
FoodSoft::load_configuration

# Makes "number_to_percentage" locale aware.
module ActionView
  module Helpers
    module NumberHelper
      alias_method :foodsoft_old_number_to_percentage, :number_to_percentage
      
      # Returns the number in the localized percentage format.
      def number_to_percentage(number, options = {})
        foodsoft_old_number_to_percentage(number, :precision => 1, :separator => FoodSoft::getDecimalSeparator)
      end      
    end
  end
end