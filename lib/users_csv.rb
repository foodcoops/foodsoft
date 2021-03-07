class UsersCsv < RenderCSV
  include ApplicationHelper

  def header
    row = [
      User.human_attribute_name(:id),
      User.human_attribute_name(:name),
      User.human_attribute_name(:nick),
      User.human_attribute_name(:first_name),
      User.human_attribute_name(:last_name),
      User.human_attribute_name(:email),
      User.human_attribute_name(:phone),
      User.human_attribute_name(:last_login),
      User.human_attribute_name(:last_activity),
      User.human_attribute_name(:iban),
      User.human_attribute_name(:ordergroup)
    ]
    row + User.custom_fields.pluck(:label)
  end

  def data
    @object.each do |o|
      row = [
        o.id,
        o.name,
        o.nick,
        o.first_name,
        o.last_name,
        o.email,
        o.phone,
        o.last_login,
        o.last_activity,
        o.iban,
        o.ordergroup&.name
      ]
      yield row + User.custom_fields.map { |f| o.settings.custom_fields[f[:name]] }
    end
  end
end
