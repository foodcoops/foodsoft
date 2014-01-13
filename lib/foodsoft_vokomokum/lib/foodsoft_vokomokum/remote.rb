require 'net/http'
require 'uri'

module FoodsoftVokomokum

  class AuthnException < Exception; end

  # validate user at Vokomokum member system from session cookie
  def self.check_user(mem)
    mem.nil? and raise AuthnException.new("Missing session cookie")
    # first get member id
    res = members_req('', mem)
    m = res.body.match(/<\s*a\s+id=['"]?profile-link['"]?\s+href=['"]?.*?\/member\/(\d+)['"]?(\s|>)/i)
    m or raise AuthnException.new("Could not find member id in Vokomokum front page, session may be invalid")
    id = m[1].to_i
    # then get member info page and obtain user data
    res = nil
    res = members_req("/member/#{id}/edit", mem)
    {
      id: id,
      first_name: get_field(res.body, 'mem_fname'),
      last_name: [get_field(res.body, 'mem_prefix'), get_field(res.body, 'mem_lname')].compact.join(' '),
      email: get_field(res.body, 'mem_email')
    }
  end

  # upload ordergroup totals to vokomokum system
  #   type can be one of 'Groente', 'Kaas', 'Misc.'
  def self.upload_amounts(amounts, type)
    # first login
    res = order_req('/cgi-bin/mem_login', {
                      'Name' => FoodsoftConfig[:vokomokum_order_user],
                      'Password' => FoodsoftConfig[:vokomokum_order_password]
    })
    unless res.body.match(/Logout/) and res.body.match(/Home/)
      raise AuthnException.new('Could not login to Vokomokum order system')
    end
    cookies = parse_cookies(res)
    # submit fresh page
    #res = order_req('/cgi-bin/vers_upload.cgi', {
    #                  'submit': type,
    #                  'paste': export_amounts(data)
    #}, cookies);
  end


  protected

  def self.members_req(path, mem)
    headers = {'Cookie' => "Mem=#{mem.gsub(/[\r\n;]/,'')}"}
    self.remote_req(FoodsoftConfig[:vokomokum_members_url], path, nil, headers)
  end

  def self.order_req(path, data=nil, cookies=nil)
    headers = {}
    headers['Cookie'] = cookies unless cookies.nil?
    self.remote_req(FoodsoftConfig[:vokomokum_order_url], path, data, headers)
  end

  def self.remote_req(url, path, data=nil, headers={})
    uri = URI.parse(url+path)
    if data.nil?
      req = Net::HTTP::Get.new(uri.request_uri)
    else
      req = Net::HTTP::Post.new(uri.request_uri)
      req.body = data
    end
    headers.each {|k,v| req[k] = v}
    res = Net::HTTP.start(uri.hostname, uri.port) {|http| http.request(req) }
    res.code.to_i == 200 or raise AuthnException.new("Could not access Vokomokum, status #{res.code}")
    res
  end

  def self.parse_cookies(res)
    # http://stackoverflow.com/a/9320190/2866660
    res.get_fields('Set-Cookie').map { |c| c.split('; ')[0] }.flatten.join('; ')
  end
  
  def self.get_field(body, name)
    m = body.match(/<\s*input\b([^>]*)\bname=(['"])#{name}\2([^>]*)>/i) or return nil
    m = m[0].match(/\bvalue=(['"])(.*?)\1/i) or return nil
    m[2]
  end

end
