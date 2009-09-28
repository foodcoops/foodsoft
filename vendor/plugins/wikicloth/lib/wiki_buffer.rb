module WikiCloth
class WikiBuffer

  def initialize(data="",options={})
    @options = options
    self.data = data
    self.buffer_type = nil
    @section_count = 0
    @buffers ||= [ ]
    @buffers << self
    @list_data = []
  end

  def run_globals?
    true
  end

  def skip_html?
    false
  end

  def data
    @data ||= ""
  end

  def params
    @params ||= [ "" ]
  end

  def buffer_type
    @buffer_type
  end

  def to_s
    "<p>" + self.params.join("\n") + "</p>"
  end

  def check_globals()
    return false if self.class != WikiBuffer

    if previous_char == "\n"
      if @indent == @buffers[-1].object_id && current_char != " "
        # close pre tag
        cc_temp = current_char
        "</pre>".each_char { |c| self.add_char(c) }
        # get the parser back on the right track
        "\n#{cc_temp}".each_char { |c| @buffers[-1].add_char(c) }
        @indent = nil
        return true
      end
      if current_char == " " && @indent.nil? && @buffers[-1].class != WikiBuffer::HTMLElement
        "<pre> ".each_char { |c| @buffers[-1].add_char(c) }
        @indent = @buffers[-1].object_id
        return true
      end
    end

    if @buffers[-1].run_globals?
      # new html tag
      if @check_new_tag == true && current_char =~ /([a-z])/ && !@buffers[-1].skip_html?
        @buffers[-1].data.chop!
        parent = @buffers[-1].element_name if @buffers[-1].class == WikiBuffer::HTMLElement
        @buffers << WikiBuffer::HTMLElement.new("",@options,parent)
      end
      @check_new_tag = current_char == '<' ? true : false

      # global
      case
      # start variable
      when previous_char == '{' && current_char == '{'
        @buffers[-1].data.chop!
        @buffers << WikiBuffer::Var.new("",@options)
        return true

      # start link
      when current_char == '[' && previous_char != '['
        @buffers << WikiBuffer::Link.new("",@options)
        return true

      # start table
      when previous_char == '{' && current_char == "|"
        @buffers[-1].data.chop!
        @buffers << WikiBuffer::Table.new("",@options)
        return true

      end
    end

    return false
  end

  def add_char(c)
    self.previous_char = self.current_char
    self.current_char = c

    if self.check_globals() == false
      case
      when @buffers.size == 1
        return self.new_char()
      when @buffers[-1].add_char(c) == false && self.class == WikiBuffer
        tmp = @buffers.pop
        @buffers[-1].data += tmp.to_s
        # any data left in the buffer we feed into the parent
        unless tmp.data.blank?
          tmp.data.each_char { |c| self.add_char(c) }
        end
      end
    end
  end

  protected
  # only executed in the default state
  def new_char()
    case
    when current_char == "\n"
      if @options[:extended_markup] == true
        self.data.gsub!(/---([^-]+)---/,"<strike>\\1</strike>")
        self.data.gsub!(/_([^_]+)_/,"<u>\\1</u>")
      end
      self.data.gsub!(/__([a-zA-Z0-9]+)__/) { |r|
        case $1
        when "NOEDITSECTION"
          @noeditsection = true
        end
        ""
      }
      self.data.gsub!(/^([-]{4,})/) { |r| "<hr />" }
      self.data.gsub!(/^([=]{1,6})\s*(.*?)\s*(\1)/) { |r|
        @section_count += 1
        "<a name='section-#{@section_count}' /><h#{$1.length}>" + (@noeditsection == true ? "" :
        "<span class=\"editsection\">[<a href=\"" + @options[:link_handler].section_link(@section_count) + 
	"\" title=\"Edit section: #{$2}\">edit</a>]</span>") +
        " <span class=\"mw-headline\">#{$2}</span></h#{$1.length}>"
      }
      self.data.gsub!(/([\']{2,5})(.*?)(\1)/) { |r|
        tmp = "<i>#{$2}</i>" if $1.length == 2
        tmp = "<b>#{$2}</b>" if $1.length == 3
        tmp = "<b>'#{$2}'</b>" if $1.length == 4
        tmp = "<b><i>#{$2}</i></b>" if $1.length == 5
        tmp
      }
      lines = self.data.split("\n")
      self.data = ""
      for line in lines
        if !@list_data.empty? && (line.blank? || line =~ /^([^#\*:;]+)/)
          tmp = ""
          @list_data.reverse!
          @list_data.each { |x| tmp += "</" + list_inner_tag_for(x) + "></#{list_tag_for(x)}>" }
          line = "#{tmp} #{line}"
          @list_data = []
        end
        line.gsub!(/^([#\*:;]+)(.*)$/) { |r|
          cdata = []
          tmp = ""
          $1.each_char { |c| cdata << c }
          if @list_data.empty?
            tmp += "<#{list_tag_for(cdata[0])}>"
            cdata[1..-1].each { |x| tmp += "<" + list_inner_tag_for(cdata[0]) + "><#{list_tag_for(x)}>" } if cdata.size > 1
          else
            case
            when cdata.size > @list_data.size
              i = cdata.size-@list_data.size
              cdata[-i,i].each { |x| tmp += "<#{list_tag_for(x)}>" }
            when cdata.size < @list_data.size
              i = @list_data.size-cdata.size
              nlist = @list_data[-i,i].reverse
              nlist.each { |x| tmp += "</" + list_inner_tag_for(x) + "></#{list_tag_for(x)}>" }
              tmp += "</#{list_inner_tag_for(cdata.last)}>"
            else
              if cdata != @list_data
                # FIXME: this will only work if the change depth is one level
                unless (@list_data.last == ';' || @list_data.last == ':') && (cdata.last == ';' || cdata.last == ':')
                  tmp += "</#{list_tag_for(@list_data.pop)}>"
                  tmp += "<#{list_tag_for(cdata.last)}>"
                end
              else
                tmp += "</" + list_inner_tag_for(@list_data.last) + ">"
              end
            end
          end
          # FIXME: still probably does not detect the : properly
          peices = cdata.last == ";" ? $2.smart_split(":") : [ $2 ]
          if peices.size > 1
            tmp += "<#{list_inner_tag_for(cdata.last)}>#{peices[0]}</#{list_inner_tag_for(cdata.last)}>"
            tmp += "<dd>#{peices[1..-1].join(":")}</dd>"
            cdata[-1] = ":"
          else
            tmp += "<#{list_inner_tag_for(cdata.last)}>#{peices[0]}"
          end
          @list_data = cdata
          tmp
        }
        self.data += line + "\n"
      end

      self.data = "</p><p>" if self.data.blank?

      self.params << self.data.auto_link
      self.data = ""
    else
      self.data += current_char
    end
    return true
  end

  def name_current_param()
    params[-1] = { :value => "", :name => params[-1] } unless params[-1].kind_of?(Hash) || params[-1].nil?
  end

  def current_param=(val)
    unless self.params[-1].nil? || self.params[-1].kind_of?(String)
      self.params[-1][:value] = val
    else
      self.params[-1] = val
    end
  end

  def params=(val)
    @params = val
  end

  def buffer_type=(val)
    @buffer_type = val
  end

  def data=(val)
    @data = val
  end

  def current_char=(val)
    @current_char = val
  end

  def current_char
    @current_char ||= ""
  end

  def previous_char=(val)
    @previous_char = val
  end

  def previous_char
    @previous_char
  end

  def current_line=(val)
    @current_line = val
  end

  def current_line
    @current_line ||= ""
  end

  def list_tag_for(tag)
    case tag
    when "#" then "ol"
    when "*" then "ul"
    when ";" then "dl"
    when ":" then "dl"
    end
  end

  def list_inner_tag_for(tag)
    case tag
    when "#" then "li"
    when "*" then "li"
    when ";" then "dt"
    when ":" then "dd"
    end
  end

end

end

require File.join(File.expand_path(File.dirname(__FILE__)), "wiki_buffer", "html_element")
require File.join(File.expand_path(File.dirname(__FILE__)), "wiki_buffer", "table")
require File.join(File.expand_path(File.dirname(__FILE__)), "wiki_buffer", "var")
require File.join(File.expand_path(File.dirname(__FILE__)), "wiki_buffer", "link")
