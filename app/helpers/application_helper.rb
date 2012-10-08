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
  # see also the plugin "will_paginate"
  def pagination_links_remote(collection, options = {})
    per_page = options[:per_page] || @per_page
    params = options[:params] || {}

    # Translations
    previous_label = '&laquo; ' + "Vorherige"
    next_label = "Nächste" + ' &raquo;'
    # Merge other url-options for will_paginate
    params = params.merge({:per_page => per_page})
    will_paginate collection, :params => params, 'data-remote' => true,
      :previous_label => previous_label, :next_label => next_label
  end
  
  # Link-collection for per_page-options when using the pagination-plugin
  def items_per_page(options = {})
    per_page_options = options[:per_page_options] || [20, 50, 100]
    current = options[:current] || @per_page
    params = params || {}

    links = per_page_options.map do |per_page|
      params.merge!({:per_page => per_page})
      per_page == current ? per_page : link_to(per_page, params, :remote => true)
    end
    "Pro Seite: #{links.join(" ")}".html_safe
  end
  
  def sort_td_class_helper(param)
    result = 'class="sortup"' if params[:sort] == param
    result = 'class="sortdown"' if params[:sort] == param + "_reverse"
    result
  end

  def sort_link_helper(text, key, options = {})
    per_page = options[:per_page] || 10
    remote = options[:remote].nil? ? true : options[:remote]
    key += "_reverse" if params[:sort] == key
    url = url_for(:sort => key, :page => nil, :per_page => per_page)

    html_options = {
        :title => "Nach #{text} sortieren",
        :remote => remote
    }

    link_to(text, url, html_options)
  end
  
  # Generates a link to the top of the website
  def link_to_top
    link_to image_tag("arrow_up_red.png", :size => "16x16", :border => "0", :alt => "Nach oben"), "#" 
  end
  
  # Returns the weekday. 0 is sunday, 1 is monday and so on
  def weekday(dayNumber)
    weekdays = ["Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag"]
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
        :delete  => { :file => 'b_drop.png', :alt => 'Löschen'},
        :edit    => { :file => 'b_edit.png', :alt => 'Bearbeiten'},
        :members => { :file => 'b_users.png', :alt => 'Mitlglieder bearbeiten'}
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
    roles << 'Admin' if record.role_admin?
    roles << 'Finanzen' if record.role_finance?
    roles << 'Lieferanten' if record.role_suppliers?
    roles << 'Artikel' if record.role_article_meta?
    roles << 'Bestellung' if record.role_orders?
    roles.join(', ')
  end

  def link_to_gmaps(address)
    link_to h(address), "http://maps.google.de/?q=#{h(address)}", :title => "Show it on google maps",
      :target => "_blank"
  end

  def bootstrap_flash
    flash_messages = []
    flash.each do |type, message|
      type = :success if type == :notice
      type = :error   if type == :alert
      text = content_tag(:div,
                         content_tag(:button, raw("&times;"), :class => "close", "data-dismiss" => "alert") +
                             message, :class => "alert fade in alert-#{type}")
      flash_messages << text if message
    end
    flash_messages.join("\n").html_safe
  end

end
