module Admin::OrdergroupsHelper
  def ordergroup_members_title(ordergroup)
    s = ''
    s += ordergroup.users.map(&:name).join(', ') if ordergroup.users.any?
    s += "\n" + Ordergroup.human_attribute_name(:contact) + ': ' + ordergroup.contact_person if ordergroup.contact_person.present?
    s
  end
end
