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
end
