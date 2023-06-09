class OrdergroupsCsv < RenderCsv
  include ApplicationHelper

  def header
    row = [
      Ordergroup.human_attribute_name(:id),
      Ordergroup.human_attribute_name(:name),
      Ordergroup.human_attribute_name(:description),
      Ordergroup.human_attribute_name(:account_balance),
      Ordergroup.human_attribute_name(:created_on),
      Ordergroup.human_attribute_name(:contact_person),
      Ordergroup.human_attribute_name(:contact_phone),
      Ordergroup.human_attribute_name(:contact_address),
      Ordergroup.human_attribute_name(:break_start),
      Ordergroup.human_attribute_name(:break_end),
      Ordergroup.human_attribute_name(:last_user_activity),
      Ordergroup.human_attribute_name(:last_order)
    ]
    row + Ordergroup.custom_fields.pluck(:label)
  end

  def data
    @object.each do |o|
      row = [
        o.id,
        o.name,
        o.description,
        o.account_balance,
        o.created_on,
        o.contact_person,
        o.contact_phone,
        o.contact_address,
        o.break_start,
        o.break_end,
        o.last_user_activity,
        o.last_order.try(:starts)
      ]
      yield row + Ordergroup.custom_fields.map { |f| o.settings.custom_fields[f[:name]] }
    end
  end
end
