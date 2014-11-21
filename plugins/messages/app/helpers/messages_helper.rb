module MessagesHelper
  def format_subject(message, length)
    if message.subject.length > length
      subject = truncate(message.subject, :length => length)
      body = ""
    else
      subject = message.subject
      body = truncate(message.body, :length => length - subject.length)
    end
    "<b>#{link_to(h(subject), message)}</b> <span style='color:grey'>#{h(body)}</span>".html_safe
  end

  def link_to_new_message(options = {})
    messages_params = options[:message_params] || nil
    link_text = content_tag :id, nil, class: 'icon-envelope'
    link_text << " #{options[:text]}" if options[:text].present?
    link_to(link_text.html_safe, new_message_path(message: messages_params), class: 'btn',
            title: I18n.t('helpers.submit.message.create'))
  end

end
