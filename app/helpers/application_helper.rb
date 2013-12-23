# encoding: utf-8
#
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def format_time(time = Time.now)
    I18n.l(time, :format => "%d.%m.%Y %H:%M") unless time.nil?
  end

  def format_date(time = Time.now)
    I18n.l(time.to_date) unless time.nil?
  end

  def format_datetime(time = Time.now)
    I18n.l(time) unless time.nil?
  end

  def format_datetime_timespec(time, format)
    I18n.l(time, :format => format) unless (time.nil? or format.nil?)
  end
  
  # Creates ajax-controlled-links for pagination
  def pagination_links_remote(collection, options = {})
    per_page = options[:per_page] || @per_page
    params = options[:params] || {}
    params = params.merge({:per_page => per_page})
    paginate collection, :params => params, :remote => true
  end
  
  # Link-collection for per_page-options when using the pagination-plugin
  def items_per_page(options = {})
    per_page_options = options[:per_page_options] || [20, 50, 100]
    current = options[:current] || @per_page
    params = params || {}

    links = per_page_options.map do |per_page|
      params.merge!({:per_page => per_page})
      link_class = 'btn'
      link_class << ' disabled' if per_page == current
      link_to(per_page, params, :remote => true, class: link_class)
    end

    content_tag :div, class: 'btn-group pull-right' do
      links.join.html_safe
    end

  end

  def sort_link_helper(text, key, options = {})
    # Hmtl options
    remote = options[:remote].nil? ? true : options[:remote]
    class_name = case params[:sort]
                   when key then
                     'sortup'
                   when key + '_reverse' then
                     'sortdown'
                   else
                     nil
                 end
    html_options = {
        :title => I18n.t('helpers.application.sort_by', text: text),
        :remote => remote,
        :class => class_name
    }


    # Url options
    key += "_reverse" if params[:sort] == key
    per_page = options[:per_page] || @per_page
    url_options = params.merge(per_page: per_page, sort: key)
    url_options.merge!({page: params[:page]}) if params[:page]
    url_options.merge!({query: params[:query]}) if params[:query]

    link_to(text, url_for(url_options), html_options)
  end

  # Generates text for table heading for model attribute
  # When the 'short' option is true, abbreviations will be used:
  #   When there is a non-empty model attribute 'foo', it looks for
  #   the model attribute translation 'foo_short' and use that as
  #   heading, with an abbreviation title of 'foo'.
  #  Other options are passed through to I18n.
  def heading_helper(model, attribute, options = {})
    i18nopts = options.select {|a| !['short'].include?(a) }
    s = model.human_attribute_name(attribute, i18nopts)
    if options[:short]
      sshort = model.human_attribute_name("#{attribute}_short".to_sym, options.merge({fallback: true, default: ''}))
      s = raw "<abbr title='#{s}'>#{sshort}</abbr>" unless sshort.blank?
    end
    s
  end
  
  # Generates a link to the top of the website
  def link_to_top
    link_to '#' do
      content_tag :i, nil, class: 'icon-arrow-up icon-large'
    end
  end
  
  # Returns the weekday. 0 is sunday, 1 is monday and so on
  def weekday(dayNumber)
    weekdays = I18n.t('date.day_names')
    return weekdays[dayNumber]
  end
  
  # to set a title for both the h1-tag and the title in the header
  def title(page_title, show_title = true)
    content_for(:title) { page_title.to_s }
    @show_title = show_title
  end

  def show_title?
    @show_title
  end

  def tab_is_active?(tab)
    tab[:active].detect {|c| controller.controller_path.match(c) }
  end

  def icon(name, options={})
    icons = {
        :delete  => { :file => 'b_drop.png', :alt => I18n.t('ui.delete')},
        :edit    => { :file => 'b_edit.png', :alt => I18n.t('ui.edit')},
        :members => { :file => 'b_users.png', :alt => I18n.t('helpers.application.edit_user')}
    }
    options[:alt] ||= icons[name][:alt]
    options[:title] ||= icons[name][:title]
    options.merge!({:size => '16x16',:border => "0"})
    
    image_tag icons[name][:file], options
  end

  # Remote links with default 'loader'.gif during request
  def remote_link_to(text, options={})
    remote_options = {
      :before => "Element.show('loader')",
      :success => "Element.hide('loader')",
      :method => :get
    }
    link_to(text, options[:url], remote_options.merge(options))
  end

  def format_roles(record)
    roles = []
    roles << I18n.t('helpers.application.role_admin') if record.role_admin?
    roles << I18n.t('helpers.application.role_finance') if record.role_finance?
    roles << I18n.t('helpers.application.role_suppliers') if record.role_suppliers?
    roles << I18n.t('helpers.application.role_article_meta') if record.role_article_meta?
    roles << I18n.t('helpers.application.role_orders') if record.role_orders?
    roles.join(', ')
  end

  def link_to_gmaps(address)
    link_to h(address), "http://maps.google.com/?q=#{h(address)}", :title => I18n.t('helpers.application.show_google_maps'),
      :target => "_blank"
  end
  
  def bootstrap_flash
    flash_messages = []
    flash.each do |type, message|
      type = :success if type == :notice
      type = :error   if type == :alert
      text = content_tag(:div,
                         content_tag(:button, I18n.t('ui.marks.close').html_safe, :class => "close", "data-dismiss" => "alert") +
                             message, :class => "alert fade in alert-#{type}")
      flash_messages << text if message
    end
    flash_messages.join("\n").html_safe
  end
  
  # render base errors in a form after failed validation
  # http://railsapps.github.io/twitter-bootstrap-rails.html
  def base_errors resource
    return '' if (resource.errors.empty?) or (resource.errors[:base].empty?)
    messages = resource.errors[:base].map { |msg| content_tag(:li, msg) }.join
    render :partial => 'shared/base_errors', :locals => {:error_messages => messages}
  end

  # show a user, depending on settings
  def show_user(user=@current_user, options = {})
    if user.nil?
      "?"
    elsif FoodsoftConfig[:use_nick]
      if options[:full] and options[:markup]
        raw "<b>#{h user.nick}</b> (#{h user.first_name} #{h user.last_name})"
      elsif options[:full]
        "#{user.nick} (#{user.first_name} #{user.last_name})"
      else
        # when use_nick was changed from false to true, users may exist without nick
        user.nick.nil? ? I18n.t('helpers.application.nick_fallback') : user.nick
      end
    else
      "#{user.first_name} #{user.last_name}" + (options[:unique] ? " (\##{user.id})" : '')
    end
  end

  # render user presentation linking to default action (write message)
  def show_user_link(user=@current_user)
    if user.nil?
      show_user user
    else
      link_to show_user(user), new_message_path('message[mail_to]' => user.id),
                               :title => I18n.t('helpers.application.write_message')
    end
  end
  
end
