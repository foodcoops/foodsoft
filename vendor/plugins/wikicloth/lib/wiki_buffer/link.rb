module WikiCloth

class WikiBuffer::Link < WikiBuffer

  def initialize(data="",options={})
    super(data,options)
    @in_quotes = false
  end

  def internal_link
    @internal_link ||= false
  end

  def to_s
    link_handler = @options[:link_handler]
    unless self.internal_link
      return link_handler.external_link("#{params[0]}".strip, "#{params[1]}".strip)
    else
      case
      when params[0] =~ /^:(.*)/
        return link_handler.link_for(params[0],params[1])
      when params[0] =~ /^\s*([a-zA-Z0-9-]+)\s*:(.*)$/
        return link_handler.link_for_resource($1,$2,params[1..-1])
      else
        return link_handler.link_for(params[0],params[1])
      end
    end
  end

  protected
  def internal_link=(val)
    @internal_link = (val == true ? true : false)
  end

  def new_char()
    case
    # check if this link is internal or external
    when previous_char.blank? && current_char == '['
      self.internal_link = true

    # Marks the beginning of another paramater for
    # the current object
    when current_char == '|' && self.internal_link == true && @in_quotes == false
      self.current_param = self.data
      self.data = ""
      self.params << ""

    # URL label
    when current_char == ' ' && self.internal_link == false && params[1].nil? && !self.data.blank?
      self.current_param = self.data
      self.data = ""
      self.params << ""

    # end of link
    when current_char == ']' && ((previous_char == ']' && self.internal_link == true) || self.internal_link == false)  && @in_quotes == false
      self.data.chop! if self.internal_link == true
      self.current_param = self.data
      self.data = ""
      return false

    else
      self.data += current_char unless current_char == ' ' && self.data.blank?
    end

    return true
  end

end

end
