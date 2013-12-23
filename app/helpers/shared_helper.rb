module SharedHelper

  # provide input_html for password autocompletion
  def autocomplete_flag_to_password_html(password_autocomplete)
    case password_autocomplete
      when true then {autocomplete: 'on'}
      when false then {autocomplete: 'off'}
      when 'store-only' then {autocomplete: 'off', data: {store: 'on'}}
      else {}
    end
  end

end
