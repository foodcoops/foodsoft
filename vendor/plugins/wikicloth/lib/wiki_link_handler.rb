require 'rubygems'
require 'builder'

module WikiCloth

class WikiLinkHandler

  def references
    @references ||= []
  end

  def section_link(section)
    ""
  end

  def params
    @params ||= {}
  end

  def external_links
    @external_links ||= []
  end

  def find_reference_by_name(n)
    references.each { |r| return r if !r[:name].nil? && r[:name].strip == n }
    return nil
  end

  def reference_index(h)
    references.each_index { |r| return r+1 if references[r] == h }
    return nil
  end

  def references=(val)
    @references = val
  end

  def params=(val)
    @params = val
  end

  def external_link(url,text)
    self.external_links << url
    elem.a({ :href => url }) { |x| x << (text.blank? ? url : text) }
  end

  def external_links=(val)
    @external_links = val
  end

  def url_for(page)
    "javascript:void(0)"
  end

  def link_attributes_for(page)
     { :href => url_for(page) }
  end

  def link_for(page, text)
    ltitle = !text.nil? && text.blank? ? self.pipe_trick(page) : text
    ltitle = page if text.nil?
    elem.a(link_attributes_for(page)) { |x| x << ltitle.strip }
  end

  def include_resource(resource, options=[])
    return self.params[resource] unless self.params[resource].nil?
  end

  def link_for_resource(prefix, resource, options=[])
    ret = ""
    prefix.downcase!
    case
    when ["image","file","media"].include?(prefix)
      ret += wiki_image(resource,options)
    else
      title = options[0] ? options[0] : "#{prefix}:#{resource}"
      ret += link_for("#{prefix}:#{resource}",title)
    end
    ret
  end

  protected
  def pipe_trick(page)
    t = page.split(":")
    t = t[1..-1] if t.size > 1
    return t.join("").split(/[,(]/)[0]
  end

  # this code needs some work... lots of work
  def wiki_image(resource,options)
      pre_img = ''
      post_img = ''
      css = []
      loc = "right"
      type = nil
      w = 180
      h = nil
      title = nil
      ffloat = false

      options.each do |x|
        case
        when ["thumb","thumbnail","frame","border"].include?(x.strip)
          type = x.strip
        when ["left","right","center","none"].include?(x.strip)
          ffloat = true
          loc = x.strip
        when x.strip =~ /^([0-9]+)\s*px$/
          w = $1
          css << "width:#{w}px"
        when x.strip =~ /^([0-9]+)\s*x\s*([0-9]+)\s*px$/
          w = $1
          css << "width:#{w}px"
          h = $2
          css << "height:#{h}px"
        else
          title = x.strip
        end
      end
      css << "float:#{loc}" if ffloat == true
      css << "border:1px solid #000" if type == "border"

      sane_title = title.nil? ? "" : title.gsub(/<\/?[^>]*>/, "")
      if type == "thumb" || type == "thumbnail" || type == "frame"
        pre_img = '<div class="thumb t' + loc + '"><div class="thumbinner" style="width: ' + w.to_s +
            'px;"><a href="" class="image" title="' + sane_title + '">'
        post_img = '</a><div class="thumbcaption">' + title + '</div></div></div>'
      end
      "#{pre_img}<img src=\"#{resource}\" alt=\"#{sane_title}\" title=\"#{sane_title}\" style=\"#{css.join(";")}\" />#{post_img}"
  end

  def elem
    Builder::XmlMarkup.new
  end

end

end
