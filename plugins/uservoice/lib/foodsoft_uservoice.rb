require "content_for_in_controllers"
require "foodsoft_uservoice/engine"

module FoodsoftUservoice
  # enabled when configured, but can still be disabled by use_uservoice option
  def self.enabled?
    FoodsoftConfig[:use_uservoice] != false and FoodsoftConfig[:uservoice]
  end

  module LoadUservoice
    def self.included(base) # :nodoc:
      base.class_eval do
        before_filter :add_uservoice_script

        protected

        def add_uservoice_script
          return unless FoodsoftUservoice.enabled?

          # include uservoice javascript
          api_key = FoodsoftConfig[:uservoice]['api_key']
          js_pre = "UserVoice=window.UserVoice||[];"
          js_load = "var uv=document.createElement('script');uv.type='text/javascript';uv.async=true;uv.src='//widget.uservoice.com/#{view_context.j api_key}.js';var s=document.getElementsByTagName('script')[0];s.parentNode.insertBefore(uv,s);"

          # configuration
          sections = FoodsoftConfig[:uservoice].reject {|k,v| k=='api_key'}
          sections.each_pair do |k,v|
            if k == 'identify'
              v['id'] = current_user.try(:id) if v.include?('id')
              v['name'] = current_user.try(:display) if v.include?('name')
              v['email'] = current_user.try(:email) if v.include?('email')
              v['created_at'] = current_user.try {|u| u.created_on.to_i} if v.include?('created_at')
            elsif k == 'set'
              v['locale'] = I18n.locale
            end
            js_load += "UserVoice.push(#{[k, v].to_json});"
          end

          # skip uservoice when serving mobile pages (using jquery mobile, a bit of a hack)
          js_load = "$(function() { if(!$('[data-role=page]')[0]){#{js_load}} });"

          # include in layout
          content_for :javascript, view_context.javascript_tag(js_pre+js_load)
        end
      end
    end
  end
end

ActiveSupport.on_load(:after_initialize) do
  ApplicationController.send :include, FoodsoftUservoice::LoadUservoice
end
