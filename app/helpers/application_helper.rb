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
    update = options[:update] || nil

    # Translations
    previous_label = '&laquo; ' + "Vorherige"
    next_label = "Nächste" + ' &raquo;'
    # Merge other url-options for will_paginate
    params = params.merge({:per_page => per_page})
    will_paginate collection, { :params => params, :remote => true, :update => update,
      :previous_label => previous_label, :next_label => next_label, }
  end
  
  # Link-collection for per_page-options when using the pagination-plugin
  def items_per_page(options = {})
    per_page_options = options[:per_page_options] || [20, 50, 100]
    current = options[:current] || @per_page
    action = options[:action] || controller.action_name
    update = options[:update] || nil

    links = []
    per_page_options.each do |per_page|
      unless per_page == current
        links << link_to_remote(
          per_page,
          { :url => { :action => action, :params => {:per_page => per_page}},
            :before => "Element.show('loader')",
            :success => "Element.hide('loader')",
            :method => :get, :update => update } )
      else
        links << per_page 
      end
    end
    return "Pro Seite: " + links.join(" ")
  end
  
  def sort_td_class_helper(param)
    result = 'class="sortup"' if params[:sort] == param
    result = 'class="sortdown"' if params[:sort] == param + "_reverse"
    return result
  end
  
  def sort_link_helper(text, key, options = {})
    per_page = options[:per_page] || 10
    action = options[:action] || "list"
    remote = options[:remote].nil? ? true : options[:remote]
    key += "_reverse" if params[:sort] == key

    link_options = {
        :url => url_for(:params => params.merge({:sort => key, :page => nil, :per_page => per_page})),
        :before => "Element.show('loader')",
        :success => "Element.hide('loader')",
        :method => :get
    }
    html_options = {
      :title => _("Nach #{text} sortieren"),
      :href => url_for(:action => action, :params => params.merge({:sort => key, :page => nil, :per_page => per_page}))
    }

    if remote
      link_to_remote(text, link_options, html_options)
    else
      link_to(text, link_options[:url], html_options)
    end
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
  
  # highlights a phrase in given text
  # based on the rails text-helper 'highlight'
  def highlight_phrase(text, phrase, highlighter = '<strong class="highlight">\1</strong>')
    unless phrase.blank? || text.nil?
      phrase.split(' ').each {|keyword| text.gsub!(/(#{Regexp.escape(keyword)})/i, highlighter)}
    end
    return text
  end
  
  # to set a title for both the h1-tag and the title in the header
  def title(page_title, show_title = true)
    @content_for_title = page_title.to_s
    @show_title = show_title
  end

  def show_title?
    @show_title
  end

  def tab_is_active?(tab)
    tab[:active].detect {|c| controller.controller_path.match(c) }
  end

  def icon(name, options={})
    icons = { :delete => { :file => 'b_drop.png', :alt => 'Löschen'},
              :edit   => { :file => 'b_edit.png', :alt => 'Bearbeiten'}}
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
    link_to_remote(text, remote_options.merge(options))
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
  
  # offers a link for writing message to user
  # checks for nil (useful for relations)
  def link_to_user_message_if_valid(user)
    user.nil? ? '??' : ( link_to user.nick, user_message_path(user), :title => _('Nachricht schreiben') )
  end

end
