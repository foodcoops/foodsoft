require 'mechanize'

class BaseConnector

  def initialize
    @agent = Mechanize.new
    @agent.redirect_ok = false
    @authorizationHeader = nil
    @form = nil
  end

  def save_form form
    fields = {}
    form.fields.each do |field|
      fields[field.name] = field.value
    end

    @form = {
      action: form.action,
      method: form.method,
      fields: fields
    }
  end

  def saved_form_field(name)
    @form && @form[:fields][name]
  end

  def submit_saved_form(fields={})

  end

  def set_authorization_header(type, token)
    @authorizationHeader = type + ' ' + token
  end

  def set_access_token_from_location_header(page)
    uri = URI.parse page.header['location']
    items = URI.decode_www_form(uri.fragment)
    accessToken = items.assoc('access_token').last
    tokenType = items.assoc('token_type').last || 'bearer'
    set_authorization_header tokenType, accessToken
    true
  end

  def get(url, data=[])
    @agent.get url, data
  end

  def post(url, data)
    @agent.post url, data
  end

  def delete(url)
    @agent.delete url
  end

  def json_headers
    ret = {'Content-Type' => 'application/json'}
    ret['Authorization'] = @authorizationHeader if @authorizationHeader
    ret
  end

  def get_json(url, data=[])
    parse_json_response @agent.get(url, data, nil, json_headers)
  end

  def post_json(url, data={})
    payload = ''
    payload = data.to_json if data
    parse_json_response @agent.post(url, payload, json_headers)
  end

  def put_json(url, data={})
    payload = ''
    payload = data.to_json if data
    parse_json_response @agent.put(url, payload, json_headers)
  end

  def parse_json_response(response)
    return nil if response.body.empty?
    JSON.parse response.body, symbolize_names: true
  end

  def load(data)
    return unless data

    io = StringIO.new data[:cookies]
    @agent.cookie_jar.load io
    @authorizationHeader = data[:authorizationHeader]
    @form = data[:form]
    @token = data[:token]
  end

  def dump
    io = StringIO.new
    @agent.cookie_jar.save io, session: true
    {
      authorizationHeader: @authorizationHeader,
      cookies: io.string,
      form: @form,
      token: @token,
    }
  end

end
