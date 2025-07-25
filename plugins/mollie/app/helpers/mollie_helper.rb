# Helper for Mollie

module MollieHelper
  # rubocop: disable Style/ConditionalAssignment

  def format_state(state)
    return nil if state.nil?

    if state['paid']
      class_name = 'state_paid'
    elsif state['open']
      class_name = 'state_open'
    elsif state['canceled']
      class_name = 'state_canceled'
    elsif state['authorized']
      class_name = 'state_authorized'
    else
      class_name = 'state_fail'
    end

    content_tag :span, I18n.t(state), class: class_name
  end
  # rubocop: enable Style/ConditionalAssignment
end
