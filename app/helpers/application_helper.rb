# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def format_time(time = Time.now)
    FoodSoft::format_date_time(time) unless time.nil?
  end

  def format_date(time = Time.now)
    FoodSoft::format_date(time) unless time.nil?
  end
  
  # Creates ajax-controlled-links for pagination
  # see also the plugin "will_paginate"
  def pagination_links_remote(collection, per_page = @per_page, params = {})
    # Translations
    prev_label = '&laquo; ' + _('Previous')
    next_label = _('Next') + ' &raquo;'
    # Merge other url-options for will_paginate
    params = params.merge({:per_page => per_page})
    will_paginate collection, {:params => params, :remote => true, :prev_label => prev_label, :next_label => next_label}
  end
  
  # Link-collection for per_page-options when using the pagination-plugin
  def items_per_page(per_page_options = [20, 50, 100], current = @per_page, action = controller.action_name)
    links = []
    per_page_options.each do |per_page|
      unless per_page == current
        links << link_to_remote(per_page, {:url => {:action => action, :params => {:per_page => per_page}},
                                           :before => "Element.show('loader')",
                                           :success => "Element.hide('loader')"})
      else
        links << per_page 
      end
    end
    return _('Per page: ') + links.join(" ")
  end
  
  def sort_td_class_helper(param)
    result = 'class="sortup"' if params[:sort] == param
    result = 'class="sortdown"' if params[:sort] == param + "_reverse"
    return result
  end
  
  def sort_link_helper(text, param, per_page = 10)
    key = param
    key += "_reverse" if params[:sort] == param
    options = {
        :url => {:action => 'list', :params => params.merge({:sort => key, :page => nil, :per_page => per_page})},
        :before => "Element.show('loader')",
        :success => "Element.hide('loader')"
    }
    html_options = {
      :title => _('Sort by this field'),
      :href => url_for(:action => 'list', :params => params.merge({:sort => key, :page => nil, :per_page => per_page}))
    }
    link_to_remote(text, options, html_options)
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
  def title(page_title)
    content_for(:title) { page_title }
  end
  
end
