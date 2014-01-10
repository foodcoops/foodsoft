require 'net/http'
require 'uri'

module FoodsoftVokomokum

  class AuthnException < Exception; end

  # validate user at Vokomokum member system from session cookie
  def self.check_user(mem)
    mem.nil? and raise AuthnException.new("Missing session cookie")
    # first get member id
    res = remote_get('', mem)
    m = res.body.match(/<\s*a\s+id=['"]?profile-link['"]?\s+href=['"]?#{@HOST}\/*member\/(\d+)['"]?(\s|>)/i)
    m or raise AuthnException.new("Could not find member id in Vokomokum front page")
    id = m[1].to_i
    # then get member info page and obtain user data
    res = nil
    res = remote_get("/member/#{id}/edit", mem)
    {
      id: id,
      first_name: get_field(res.body, 'mem_fname'),
      last_name: [get_field(res.body, 'mem_prefix'), get_field(res.body, 'mem_lname')].compact.join(' '),
      email: get_field(res.body, 'mem_email')
    }
  end


  protected

  def self.remote_get(path, mem)
    uri = URI.parse(FoodsoftConfig[:vokomokum_login_url]+path)
    req = Net::HTTP::Get.new(uri.request_uri)
    req['Cookie'] = "Mem=#{mem.gsub(/[\r\n;]/,'')}"
    res = Net::HTTP.start(uri.hostname, uri.port) {|http| http.request(req) }
    res.code.to_i == 200 or raise AuthnException.new("Could not access Vokomokum, status #{res.code}")
    res
  end
  
  def self.get_field(body, name)
    m = body.match(/<\s*input\b([^>]*)\bname=(['"])#{name}\2([^>]*)>/) or return nil
    m = m[0].match(/\bvalue=(['"])(.*?)\1/) or return nil
    m[2]
  end

end
