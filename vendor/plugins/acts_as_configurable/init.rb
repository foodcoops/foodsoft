
require 'acts_as_configurable'
ActiveRecord::Base.send(:include, Nkryptic::ActsAsConfigurable)

require 'configurable_setting'