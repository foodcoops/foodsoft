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
    truncate "<b>#{link_to(h(message.subject), message)}</b> <span style='color:grey'>#{h(message.body)}</span>", :length => length
  end
end
