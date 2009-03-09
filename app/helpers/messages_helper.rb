module MessagesHelper
  def groups_for_select
    groups = [[" -- Arbeitsgruppen -- ", ""]]
    groups += Workgroup.find(:all, :order => 'name', :include => :memberships).reject{ |g| g.memberships.empty? }.collect do |g|
      [g.name, g.id]
    end
    groups += [[" -- Bestellgruppen -- ", ""]]
    groups += Ordergroup.without_deleted(:order => 'name', :include => :memberships).reject{ |g| g.memberships.empty? }.collect do |g|
      [g.name, g.id]
    end
    groups
  end

  def format_subject(message, length)
    if message.subject.length > length
      subject = truncate(message.subject, :length => length)
      body = ""
    else
      subject = message.subject
      body = truncate(message.body, :length => length - subject.length)
    end
    "<b>#{link_to(h(subject), message)}</b> <span style='color:grey'>#{h(body)}</span>"
  end
end
