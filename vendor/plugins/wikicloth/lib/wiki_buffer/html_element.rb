require 'rubygems'
require 'builder'

module WikiCloth

class WikiBuffer::HTMLElement < WikiBuffer

  ALLOWED_ELEMENTS = ['a','b','i','div','span','sup','sub','strike','s','u','font','big','ref','tt','del',
	'small','blockquote','strong','pre','code','references','ol','li','ul','dd','dt','dl','center',
	'h2','h3','h4','h5','h6']
  ALLOWED_ATTRIBUTES = ['id','name','style','class','href','start','value']
  ESCAPED_TAGS = [ 'nowiki', 'pre', 'code' ]
  SHORT_TAGS = [ 'meta','br','hr','img' ]
  NO_NEED_TO_CLOSE = ['li','p'] + SHORT_TAGS

  def initialize(d="",options={},check=nil)
    super("",options)
    self.buffer_type = "Element"
    @in_quotes = false
    @in_single_quotes = false
    @start_tag = 1
    @tag_check = check unless check.nil?
  end

  def run_globals?
    return ESCAPED_TAGS.include?(self.element_name) ? false : true
  end

  def to_s
    if NO_NEED_TO_CLOSE.include?(self.element_name)
      return "<#{self.element_name} />" if SHORT_TAGS.include?(self.element_name)
      return "</#{self.element_name}><#{self.element_name}>" if @tag_check == self.element_name
    end

    if ESCAPED_TAGS.include?(self.element_name)
      # escape all html inside this element
      self.element_content = self.element_content.gsub('<','&lt;').gsub('>','&gt;')
      # hack to fix <code><nowiki> nested mess
      self.element_content = self.element_content.gsub(/&lt;[\/]*\s*nowiki\s*&gt;/,'')
    end

    lhandler = @options[:link_handler]
    case self.element_name
    when "ref"
      self.element_name = "sup"
      named_ref = self.name_attribute
      ref = lhandler.find_reference_by_name(named_ref) unless named_ref.nil?
      if ref.nil?
        lhandler.references << { :name => named_ref, :value => self.element_content, :count => 0 }
        ref = lhandler.references.last
      end
      ref_id = (named_ref.nil? ? "" : "#{named_ref}_") + "#{lhandler.reference_index(ref)}-#{ref[:count]}"
      self.params << { :name => "id", :value => "cite_ref-#{ref_id}" }
      self.params << { :name => "class", :value => "reference" }
      self.element_content = "[<a href=\"#cite_note-" + (named_ref.nil? ? "" : "#{named_ref}_") + 
	"#{lhandler.reference_index(ref)}\">#{lhandler.reference_index(ref)}</a>]"
      ref[:count] += 1
    when "references"
      ref_count = 0
      self.element_name = "ol"
      self.element_content = lhandler.references.collect { |r| 
        ref_count += 1
        ref_name = (r[:name].nil? ? "" : r[:name].to_slug + "_")
        ret = "<li id=\"cite_note-#{ref_name}#{ref_count}\"><b>"
        1.upto(r[:count]) { |x| ret += "<a href=\"#cite_ref-#{ref_name}#{ref_count}-#{x-1}\">" + 
		(r[:count] == 1 ? "^" : (x-1).to_s(26).tr('0-9a-p', 'a-z')) + "</a> " }
        ret += "</b> #{r[:value]}</li>"
      }.to_s
    when "nowiki"
      return self.element_content
    end

    tmp = elem.tag!(self.element_name, self.element_attributes) { |x| x << self.element_content }
    unless ALLOWED_ELEMENTS.include?(self.element_name)
      tmp.gsub!(/[\-!\|&"\{\}\[\]]/) { |r| self.escape_char(r) }
      return tmp.gsub('<', '&lt;').gsub('>', '&gt;')
    end
    tmp
  end

  def name_attribute
    params.each { |p| return p[:value].to_slug if p.kind_of?(Hash) && p[:name] == "name" }
    return nil
  end

  def element_attributes
    attr = {}
    params.each { |p| attr[p[:name]] = p[:value] if p.kind_of?(Hash) }
    if ALLOWED_ELEMENTS.include?(self.element_name.strip.downcase)
      attr.delete_if { |key,value| !ALLOWED_ATTRIBUTES.include?(key.strip) }
    end
    return attr
  end

  def element_name
    @ename ||= ""
  end

  def element_content
    @econtent ||= ""
  end

  protected

  def escape_char(c)
    c = case c
    when '-' then '&#45;'
    when '!' then '&#33;'
    when '|' then '&#124;'
    when '&' then '&amp;'
    when '"' then '&quot;'
    when '{' then '&#123;'
    when '}' then '&#125;'
    when '[' then '&#91;'
    when ']' then '&#93;'
    when '*' then '&#42;'
    when '#' then '&#35;'
    when ':' then '&#58;'
    when ';' then '&#59;'
    when "'" then '&#39;'
    when '=' then '&#61;'
    else
      c
    end
    return c
  end

  def elem
    Builder::XmlMarkup.new
  end

  def element_name=(val)
    @ename = val
  end

  def element_content=(val)
    @econtent = val
  end

  def in_quotes?
    @in_quotes || @in_single_quotes ? true : false
  end

  def new_char()
    case
    # tag name
    when @start_tag == 1 && current_char == ' '
      self.element_name = self.data.strip.downcase
      self.data = ""
      @start_tag = 2

    # tag is closed <tag/> no attributes
    when @start_tag == 1 && previous_char == '/' && current_char == '>'
      self.data.chop!
      self.element_name = self.data.strip.downcase
      self.data = ""
      @start_tag = 0
      return false

    # open tag
    when @start_tag == 1 && previous_char != '/' && current_char == '>'
      self.element_name = self.data.strip.downcase
      self.data = ""
      @start_tag = 0
      return false if SHORT_TAGS.include?(self.element_name)
      return false if self.element_name == @tag_check && NO_NEED_TO_CLOSE.include?(self.element_name)

    # new tag attr
    when @start_tag == 2 && current_char == ' ' && self.in_quotes? == false
      self.current_param = self.data
      self.data = ""
      self.params << ""

    # tag attribute name
    when @start_tag == 2 && current_char == '=' && self.in_quotes? == false
      self.current_param = self.data
      self.data = ""
      self.name_current_param()

    # tag is now open
    when @start_tag == 2 && previous_char != '/' && current_char == '>'
      self.current_param = self.data
      self.data = ""
      @start_tag = 0
      return false if SHORT_TAGS.include?(self.element_name)
      return false if self.element_name == @tag_check && NO_NEED_TO_CLOSE.include?(self.element_name)

    # tag is closed <example/>
    when @start_tag == 2 && previous_char == '/' && current_char == '>'
      self.current_param = self.data.chop
      self.data = ""
      @start_tag = 0
      return false

    # in quotes
    when @start_tag == 2 && current_char == "'" && previous_char != '\\' && !@in_quotes
      @in_single_quotes = !@in_single_quotes

    # in quotes
    when @start_tag == 2 && current_char == '"' && previous_char != '\\' && !@in_single_quotes
      @in_quotes = !@in_quotes

    # start of a closing tag
    when @start_tag == 0 && previous_char == '<' && current_char == '/'
      self.element_content += self.data.chop
      self.data = ""
      @start_tag = 5

    when @start_tag == 5 && (current_char == '>' || current_char == ' ') && !self.data.blank?
      self.data = self.data.strip.downcase
      if self.data == self.element_name
        self.data = ""
        return false
      else
        if @tag_check == self.data && NO_NEED_TO_CLOSE.include?(self.element_name)
          self.data = "</#{self.data}>"
          return false
        else
          self.element_content += "&lt;/#{self.data}&gt;"
          @start_tag = 0
          self.data = ""
        end
      end

    else
      if @start_tag == 0 && ESCAPED_TAGS.include?(self.element_name)
        self.data += self.escape_char(current_char)
      else
        self.data += current_char
      end
    end
    return true
  end

end

end
