
module Nkryptic # :nodoc:
  module ActsAsConfigurable #:nodoc:
    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end
    
    # These methods will be available to any ActiveRecord::Base descended model.
    module ClassMethods
      
      # == Acts As Configurable
      # requirements:: 
      #   model descended from ActiveRecord::Base
      #   configurable_settings table has been created
      #
      #   class User < ActiveRecord::Base
      #     acts_as_configurable
      #   end
      #
      # This mixin will provide your model with a large variety of configuration options.
      # 
      # see:: settings and settins_for
      #
      def acts_as_configurable(options = {})
        
        # don't allow multiple calls
        return if self.included_modules.include?(Nkryptic::ActsAsConfigurable::InstanceMethods)
        send :include, Nkryptic::ActsAsConfigurable::InstanceMethods
        
        cattr_accessor :defaults
        self.defaults = (options.class == Hash ? options : {}).with_indifferent_access
        
        has_many  :_configurable_settings,
                  :as           => :configurable,
                  :class_name   => 'ConfigurableSetting',
                  :dependent    => :destroy

      end
      
      # == Acts As Configurable Target
      # requirements:: 
      #   model descended from ActiveRecord::Base
      #   configurable_settings table has been created
      #
      #   class User < ActiveRecord::Base
      #     acts_as_configurable_target
      #   end
      #
      # This mixin will provide your model with the ability to see where it is used as a target of acts_as_configurable
      #
      # see:: targetable_settings and targetable_settings_for
      #
      def acts_as_configurable_target(options = {})
        return if self.included_modules.include?(Nkryptic::ActsAsConfigurable::TargetInstanceMethods)
        send :include, Nkryptic::ActsAsConfigurable::TargetInstanceMethods
        
        has_many  :_targetable_settings,
                  :as           => :targetable,
                  :class_name   => 'ConfigurableSetting',
                  :dependent    => :destroy
                  
      end
    end

    module InstanceMethods
      
      def self.included(base) # :nodoc:
        base.extend Nkryptic::ActsAsConfigurable::InstanceMethods::ClassMethods
      end
      
      # * specify any setting you want for an instance of a model
      #
      # Example:
      #
      #   user = User.create(:name => 'joe')
      #   user.settings                     # => []
      #
      #   user.settings[:friends] = ['jane','sam','karl']
      #   user.settings[:friends]           # => ['jane','sam','karl']
      #   user.settings[:age] = 25
      #   user.settings[:age]               # => 25
      #
      def settings
        @general_settings ||= ConfigurableSettings.new(self)
      end
      
      # * specify any setting you want for an instance of a model targeting another object
      #
      # Example:
      #   
      #   user = User.create(:name => 'joe')
      #   post = Post.find(:first)
      #
      #   user.settings_for(post)          # => []
      #   user.settings_for(post)[:show_headlines] = true
      #
      #   user.settings_for(post)[:show_headlines]   # => true
      #   user.settings_for(post).size     # => 1
      #
      #   # but the user's untargeted settings are still empty
      #   user.settings                    # => []
      #
      def settings_for(obj)
        if obj.is_a? Class
          # wire the settings object to only deal with settings targeting this class obj
          variable_name = "settings_for_class_#{obj.name}"
        else
          # wire the settings object to only deal with settings targeting this instance obj
          variable_name = "settings_for_#{obj.class}_#{obj.id}"
        end
        settings_obj = instance_variable_get("@#{variable_name}") 
        settings_obj = instance_variable_set("@#{variable_name}",ConfigurableSettings.new(self, obj)) if settings_obj.nil?
        settings_obj
      end

      # These are class methods that are mixed in with the model class.
      module ClassMethods # :nodoc:
        
      end
    end
    
    module TargetInstanceMethods
      
      def self.included(base) # :nodoc:
        base.extend Nkryptic::ActsAsConfigurable::TargetInstanceMethods::ClassMethods
      end
      
      # * specify any setting you want for an instance of a model targeting another object
      #
      # Example:
      #   
      #   user = User.create(:name => 'joe')
      #   post = Post.find(:first)
      #
      #   user.settings_for(post)          # => []
      #   user.settings_for(post)[:num_lines] = 15
      #
      #   user.settings_for(post)[:num_lines]   # => 15
      #   post.targeted_settings[:num_lines].size  # => 1
      #   post.targeted_settings[:num_lines].first   # => 15
      #   post.targeted_settings[:num_lines].first.owner   # => user
      #
      def targeted_settings
        @targeted_settings ||= TargetedSettings.new(self)
      end
      
      # * specify any setting you want for an instance of a model targeting another object
      #
      # Example:
      #   
      #   user = User.create(:name => 'joe')
      #   post = Post.find(:first)
      #
      #   user.settings_for(post)          # => []
      #   user.settings_for(post)[:num_lines] = 15
      #
      #   user.settings_for(post)[:num_lines]   # => 15
      #   user.settings_for(post)[:hide_comments]   # => true
      #   post.targeted_settings_for(user)[:num_lines]   # => 15
      #   post.targeted_settings_for(user)   # => [15,true]
      #   post.targeted_settings_for(user).collect {|x| x.name}   # => ['num_lines','hide_comments']
      #
      def targeted_settings_for(obj)
        if obj.is_a? Class
          # wire the targeted_settings object to only deal with settings targeting this class obj
          variable_name = "targeted_settings_for_class_#{obj.name}"
        else
          # wire the targeted_settings object to only deal with settings targeting this instance obj
          variable_name = "targeted_settings_for_#{obj.class}_#{obj.id}"
        end
        settings_obj = instance_variable_get("@#{variable_name}") 
        settings_obj = instance_variable_set("@#{variable_name}",TargetedSettings.new(self, obj)) if settings_obj.nil?
        settings_obj
      end
      
      # These are class methods that are mixed in with the model class.
      module ClassMethods # :nodoc:
        
      end
    end
    
    
    class ProxySettings # :nodoc:
      alias_method '__class', 'class'
      instance_methods.each { |m| undef_method m unless m =~ /(^__|^nil\?$|^send$)/ }
      
      #class_inheritable_accessor(:sql_word)
      
      def initialize(source, reference=nil)        
        @source = source
        @reference = reference
        true   
      end
      
      def real_class
        __class
      end
      
      def settings
        @source.send(@settings)
      end
      
      def to_ary
        find_settings.collect do |x|
          ProxySetting.new(x)
        end
      end
      
      def responds_to?(what)
        settings.responds_to?(what)
      end
      
      def ==(what)
        find_settings == what
      end
      
      def size
        find_settings.size
      end
      
      def inspect
        find_settings.inspect
      end
      
      def each(&block)
        find_settings.each do |x|
          yield ProxySetting.new(x)
        end
      end
      
      def each_with_key(&block)
        find_settings.each do |x|
          yield(x.name, ProxySetting.new(x))
        end
      end
      
      def select(&block)
        find_settings.select do |x|
          yield ProxySetting.new(x)
        end
      end
      
      def reject(&block)
        find_settings.reject do |x|
          yield ProxySetting.new(x)
        end
      end
      
      def collect(&block)
        find_settings.collect do |x|
          yield ProxySetting.new(x)
        end
      end
      
      def has_key?(name)
        name = name.to_s
        setting = find_setting(name)
        if setting.nil? 
          false
        else
          if setting.is_a? Array
            setting.size == 0 ? false : true
          else
            true
          end
        end
      end        
      
      def [](name)        
        name = name.to_s
        setting = find_setting(name)
        return nil if setting.nil?
        if setting.is_a? Array
          setting.collect {|x| ProxySetting.new(x)}
        else
          ProxySetting.new(setting)
        end
      end

      def []=(name, value) 
        name = name.to_s
        setting = find_setting(name)
        if setting.is_a? Array
          setting.collect do |x| 
            x.value_type = value.class.to_s
            x.value = value.to_yaml
            x.save
            ProxySetting.new(x)
          end
        else
          if setting.nil?
            setting = create_setting(name)
          end
          setting.value_type = value.class.to_s
          setting.value = value.to_yaml
          setting.save
          ProxySetting.new(setting)
        end
      end
      
      private
      
      def find_settings; nil end
      
      def find_setting(name); nil end
      
      def create_setting(name); nil end
      
      def method_missing(method, *args, &block)
        settings.send(method, *args, &block)
      end
      
    end

    class ConfigurableSettings < ProxySettings # :nodoc:
      
      def initialize(source, reference=nil)
        super
        @settings = '_configurable_settings'
        @@sql_word = "targetable"
        true   
      end
      
      private
      
      def find_settings
        if @reference.is_a? Class
          settings.find( :all, 
              :conditions => [ "#{@@sql_word}_type = ? and #{@@sql_word}_id IS NULL", @reference.to_s ] )
        elsif @reference
          settings.find( :all, 
              :conditions => [ "#{@@sql_word}_type = ? and #{@@sql_word}_id = ?", @reference.class.to_s, @reference.id ] )
        else
          settings.find( :all, 
              :conditions => [ "#{@@sql_word}_type is null and #{@@sql_word}_id is null" ] )
        end
      end
      
      def find_setting(name)
        if @reference.is_a? Class
          settings.find( :first, 
              :conditions => [ "name = ? and #{@@sql_word}_type = ? and #{@@sql_word}_id IS NULL", name, @reference.to_s ] )
        elsif @reference
          settings.find( :first, 
              :conditions => [ "name = ? and #{@@sql_word}_type = ? and #{@@sql_word}_id = ?", name, @reference.class.to_s, @reference.id ] )
        else
          settings.find( :first, 
              :conditions => [ "name = ? and #{@@sql_word}_type is null and #{@@sql_word}_id is null", name ] )
        end
      end
      
      def create_setting(name)
        if @reference.is_a? Class
          settings.create( :name => name, "#{@@sql_word}_type" => @reference.to_s )
        elsif @reference
          settings.create( :name => name, "#{@@sql_word}_type" => @reference.class.to_s, "#{@@sql_word}_id" => @reference.id )
        else
          settings.create( :name => name )
        end
      end
      
    end
    
    class TargetedSettings < ProxySettings # :nodoc:
      
      def initialize(target, owner=nil)
        super
        @settings = '_targetable_settings'      
        @@sql_word = "configurable"
        true   
      end
      
      private
      
      def find_settings
        if @reference.is_a? Class
          settings.find( :all, 
              :conditions => [ "#{@@sql_word}_type = ? and #{@@sql_word}_id IS NULL", @reference.to_s ] )
        elsif @reference
          settings.find( :all, 
              :conditions => [ "#{@@sql_word}_type = ? and #{@@sql_word}_id = ?", @reference.class.to_s, @reference.id ] )
        else
          settings.find( :all )
        end
      end
      
      def find_setting(name)
        if @reference.is_a? Class
          settings.find( :first, 
              :conditions => [ "name = ? and #{@@sql_word}_type = ? and #{@@sql_word}_id IS NULL", name, @reference.to_s ] )
        elsif @reference
          settings.find( :first, 
              :conditions => [ "name = ? and #{@@sql_word}_type = ? and #{@@sql_word}_id = ?", name, @reference.class.to_s, @reference.id ] )
        else
          settings.find( :all, 
              :conditions => [ "name = ?", name ] )
        end
      end
      
      def create_setting(name)
        if @reference.is_a? Class
          settings.create( :name => name, "#{@@sql_word}_type" => @reference.to_s )
        elsif @reference
          settings.create( :name => name, "#{@@sql_word}_type" => @reference.class.to_s, "#{@@sql_word}_id" => @reference.id )
        end
      end

    end
    
    class ProxySetting # :nodoc:
      
      alias_method '__class', 'class'
      instance_methods.each { |m| undef_method m unless m =~ /(^__|^nil\?$|^send$)/ }
      
      def initialize(setting)
        @_setting = setting
        true   
      end
      
      def real_class
        ProxySetting
      end
      
      def target
        unless @_setting.targetable_type.blank? or @_setting.targetable_id.blank?
          ConfigurableSetting.find_targetable(@_setting.targetable_type, @_setting.targetable_id)
        else
          nil
        end
      end
      
      def owner
        unless @_setting.configurable_type.blank? or @_setting.configurable_id.blank?
          ConfigurableSetting.find_configurable(@_setting.configurable_type, @_setting.configurable_id)
        else
          nil
        end
      end
      
      def []=(name, val)
        obj = self.value
        if obj.responds_to? '[]='
          obj[name] = val
          self.value = obj
          self.save
        else
          method_missing('[]=', [name,val])
        end
      end
      
      def delete(name)
        obj = self.value
        if obj.responds_to? 'delete'
          obj.delete(name)
          self.value = obj
          self.save
        else
          method_missing('delete', [name,val])
        end
      end
      
      def save
        @_setting.save
      end
      
      protected
      
      def value
        @value ||= YAML.load(@_setting.value)
      end
      
      def value=(val)
        @value = val
        self.set_value
      end
      
      def set_value
        @_setting.value_type = @value.class.to_s
        @_setting.value = @value.to_yaml
      end
      
      private
      
      def method_missing(method, *args, &block)
        return_value = self.value.send(method, *args, &block)
        if @value != YAML.load(@_setting.value)
          STDERR.puts "#{method} called with args #{args} for ProxySetting"
          self.set_value
        end
        return_value
      end

    end
    

  end
end