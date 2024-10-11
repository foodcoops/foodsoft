#
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include PathHelper

  def format_time(time = Time.now)
    I18n.l(time, format: :foodsoft_datetime) unless time.nil?
  end

  def format_date(time = Time.now)
    I18n.l(time.to_date) unless time.nil?
  end

  def format_datetime(time = Time.now)
    I18n.l(time) unless time.nil?
  end

  def format_datetime_timespec(time, format)
    I18n.l(time, format: format) unless time.nil? || format.nil?
  end

  def format_currency(amount)
    return nil if amount.nil?

    class_name = amount < 0 ? 'negative_amout' : 'positive_amount'
    content_tag :span, number_to_currency(amount), class: class_name
  end

  # Splits an IBAN into groups of 4 digits displayed with margins in between
  def format_iban(iban)
    iban && iban.scan(/..?.?.?/).map { |item| content_tag(:span, item, style: 'margin-right: 0.5em;') }.join.html_safe
  end

  # Creates ajax-controlled-links for pagination
  def pagination_links_remote(collection, options = {})
    per_page = options[:per_page] || @per_page
    params = options[:params] || {}
    params = params.merge({ per_page: per_page })
    paginate collection, params: params, remote: true
  end

  # Link-collection for per_page-options when using the pagination-plugin
  def items_per_page(options = {})
    per_page_options = options[:per_page_options] || [20, 50, 100, 500]
    current = options[:current] || @per_page
    params ||= {}

    links = per_page_options.map do |per_page|
      params.merge!({ per_page: per_page })
      link_class = 'btn'
      link_class << ' disabled' if per_page == current
      link_to(per_page, params, remote: true, class: link_class)
    end

    if options[:wrap] == false
      links.join.html_safe
    else
      content_tag :div, class: 'btn-group pull-right' do
        links.join.html_safe
      end
    end
  end

  def sort_link_helper(text, key, options = {})
    # Hmtl options
    remote = options[:remote].nil? ? true : options[:remote]
    class_name = case params[:sort]
                 when key
                   'sortup'
                 when key + '_reverse'
                   'sortdown'
                 end
    html_options = {
      title: I18n.t('helpers.application.sort_by', text: text),
      remote: remote,
      class: class_name
    }

    # Url options
    key += '_reverse' if params[:sort] == key
    per_page = options[:per_page] || @per_page
    url_options = params.merge(per_page: per_page, sort: key)
    url_options.merge!({ page: params[:page] }) if params[:page]
    url_options.merge!({ query: params[:query] }) if params[:query]

    link_to(text, url_for(url_options), html_options)
  end

  # Generates text for table heading for model attribute
  # When the 'short' option is true, abbreviations will be used:
  #   When there is a non-empty model attribute 'foo', it looks for
  #   the model attribute translation 'foo_short' and use that as
  #   heading, with an abbreviation title of 'foo'. If a translation
  #   'foo_desc' is present, that is used instead, but that can be
  #   be overridden by the option 'desc'.
  #  Other options are passed through to I18n.
  def heading_helper(model, attribute, options = {})
    i18nopts = { count: 2 }.merge(options.select { |a| !%w[short desc].include?(a) })
    s = model.human_attribute_name(attribute, i18nopts)
    if options[:short]
      desc = options[:desc]
      desc ||= model.human_attribute_name(:"#{attribute}_desc",
                                          options.merge({ fallback: true, default: '', count: 2 }))
      desc.blank? && desc = s
      sshort = model.human_attribute_name(:"#{attribute}_short",
                                          options.merge({ fallback: true, default: '', count: 2 }))
      s = raw "<abbr title='#{desc}'>#{sshort}</abbr>" if sshort.present?
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
    weekdays[dayNumber]
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
    tab[:active].detect { |c| controller.controller_path.match(c) }
  end

  def icon(name, options = {})
    icons = {
      delete: { file: 'b_drop.png', alt: I18n.t('ui.delete') },
      edit: { file: 'b_edit.png', alt: I18n.t('ui.edit') },
      members: { file: 'b_users.png', alt: I18n.t('helpers.application.edit_user') }
    }
    options[:alt] ||= icons[name][:alt]
    options[:title] ||= icons[name][:title]
    options.merge!({ size: '16x16', border: '0' })

    image_tag icons[name][:file], options
  end

  # Remote links with default 'loader'.gif during request
  def remote_link_to(text, options = {})
    remote_options = {
      before: "Element.show('loader')",
      success: "Element.hide('loader')",
      method: :get
    }
    link_to(text, options[:url], remote_options.merge(options))
  end

  def format_roles(record, icon = false)
    roles = %w[suppliers article_meta orders pickups finance invoices admin]
    roles.select! { |role| record.send "role_#{role}?" }
    names = roles.index_with { |r| I18n.t("helpers.application.role_#{r}") }
    if icon
      roles.map do |r|
        image_tag("role-#{r}.png", size: '22x22', border: 0, alt: names[r], title: names[r])
      end.join('&nbsp;').html_safe
    else
      roles.map { |r| names[r] }.join(', ')
    end
  end

  def link_to_gmaps(address)
    link_to h(address), "http://maps.google.com/?q=#{h(address)}", title: I18n.t('helpers.application.show_google_maps'),
                                                                   target: '_blank', rel: 'noopener'
  end

  # Returns flash messages html.
  #
  # Use this instead of twitter-bootstrap's +bootstrap_flash+ method for safety, until
  # CVE-2014-4920 is fixed.
  #
  # @return [String] Flash message html.
  # @see http://blog.nvisium.com/2014/03/reflected-xss-vulnerability-in-twitter.html
  def bootstrap_flash_patched
    flash_messages = []
    flash.each do |type, message|
      type = :success if type == 'notice'
      type = :error   if type == 'alert'
      text = content_tag(:div,
                         content_tag(:button, I18n.t('ui.marks.close').html_safe, :class => 'close', 'data-dismiss' => 'alert') +
                             message, class: "alert fade in alert-#{type}")
      flash_messages << text if message
    end
    flash_messages.join("\n").html_safe
  end

  # render base errors in a form after failed validation
  # http://railsapps.github.io/twitter-bootstrap-rails.html
  def base_errors(resource)
    return '' if resource.errors.empty? || resource.errors[:base].empty?

    messages = resource.errors[:base].map { |msg| content_tag(:li, msg) }.join
    render partial: 'shared/base_errors', locals: { error_messages: messages }
  end

  # show a user, depending on settings
  def show_user(user = @current_user, options = {})
    if user.nil?
      '?'
    elsif FoodsoftConfig[:use_nick]
      if options[:full] && options[:markup]
        raw "<b>#{h user.nick}</b> (#{h user.first_name} #{h user.last_name})"
      elsif options[:full]
        "#{user.nick} (#{user.first_name} #{user.last_name})"
      else
        # when use_nick was changed from false to true, users may exist without nick
        user.nick.nil? ? I18n.t('helpers.application.nick_fallback') : user.nick
      end
    else
      "#{user.first_name} #{user.last_name}" + (options[:unique] ? " (##{user.id})" : '')
    end
  end

  # render user presentation linking to default action (plugins can override this)
  def show_user_link(user = @current_user)
    show_user user
  end

  # allow truncate to add title when tooltip option is given
  def truncate(text, options = {}, &block)
    return text if !text || text.length <= (options[:length] || 30)

    text_truncated = super(text, options, &block)
    if options[:tooltip]
      content_tag :span, text_truncated, title: text
    else
      text_truncated
    end
  end

  # Expand variables in text
  # @see Foodsoft::ExpansionVariables#expand
  def expand(text, options = {})
    Foodsoft::ExpansionVariables.expand(text, options)
  end

  # @param dismiss [String, Symbol] Bootstrap dismiss value (modal, alert)
  # @return [String] HTML for close button dismissing
  def close_button(dismiss)
    content_tag :button, type: 'button', class: 'close', data: { dismiss: dismiss } do
      I18n.t('ui.marks.close').html_safe
    end
  end

  # @return [String] path to foodcoop CSS style (with MD5 parameter for caching)
  def foodcoop_css_path(options = {})
    super(options.merge({ md5: Digest::MD5.hexdigest(FoodsoftConfig[:custom_css].to_s) }))
  end

  # @return [String] stylesheet tag for foodcoop CSS style (+custom_css+ foodcoop config)
  # @see #foodcoop_css_path
  def foodcoop_css_tag(_options = {})
    return if FoodsoftConfig[:custom_css].blank?

    stylesheet_link_tag foodcoop_css_path, media: 'all'
  end

  def format_number(value, max_precision = 2)
    number_with_precision(value, precision: max_precision, strip_insignificant_zeros: true, separator: '.', delimiter: '')
  end
end
