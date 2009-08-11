module WikiCloth

class WikiBuffer::Var < WikiBuffer

  def initialize(data="",options={})
    super(data,options)
    self.buffer_type = "var"
    @in_quotes = false
  end

  def skip_html?
    true
  end

  def function_name
    @fname
  end

  def to_s
    if self.is_function?
      ret = "#{buffer_type}"
      ret += " function #{function_name}"
      ret += "(#{params.inspect})"
      ret += " [#{data}]"
    else
      ret = @options[:link_handler].include_resource("#{params[0]}".strip,params[1..-1])
    end
    ret ||= "<!-- TEMPLATE[#{params[0]}] NOT FOUND -->"
    ret
  end

  def is_function?
    self.function_name.nil? || self.function_name.blank? ? false : true
  end

  protected
  def function_name=(val)
    @fname = val
  end

  def new_char()
    case
    when current_char == '|' && @in_quotes == false
      self.current_param = self.data
      self.data = ""
      self.params << ""

    # Start of either a function or a namespace change
    when current_char == ':' && @in_quotes == false && self.params.size <= 1
      self.function_name = self.data
      self.data = ""
      puts "[found var function (#{function_name})"

    # Dealing with variable names within functions
    # and variables
    when current_char == '=' && @in_quotes == false
      self.current_param = self.data
      self.data = ""
      self.name_current_param()

    # End of a template, variable, or function
    when current_char == '}' && previous_char == '}'
      self.data.chop!
      self.current_param = self.data
      self.data = ""
      return false

    else
      self.data += current_char
    end

    return true
  end

end

end
