module WikiCloth

class WikiBuffer::Table < WikiBuffer

  def initialize(data="",options={})
    super(data,options)
    self.buffer_type = "table"
    @start_table = true
    @start_row = false
    @start_caption = false
    @in_quotes = false
  end

  def table_caption
    @caption ||= ""
    return @caption.kind_of?(Hash) ? @caption[:value] : @caption
  end

  def table_caption_attributes
    @caption.kind_of?(Hash) ? @caption[:style] : ""
  end

  def rows
    @rows ||= [ [] ]
  end

  def to_s
    row_count = 0
    ret = "<table" + (params[0].blank? ? "" : " #{params[0].strip}") + ">"
    ret += "<caption" + (self.table_caption_attributes.blank? ? "" : " #{table_caption_attributes.strip}") + 
	">#{table_caption.strip}</caption>" unless self.table_caption.blank?
    for row in rows
      row_count += 1
      ret += "<tr" + (params[row_count].nil? || params[row_count].blank? ? "" : " #{params[row_count].strip}") + ">"
      for cell in row
          cell_attributes = cell[:style].blank? ? "" : " #{cell[:style].strip}"
          ret += "<#{cell[:type]}#{cell_attributes}>\n#{cell[:value].strip}\n</#{cell[:type]}>"
      end
      ret += "</tr>"
    end
    ret += "</table>"
  end

  protected
  def rows=(val)
    @rows = val
  end

  def table_caption_attributes=(val)
    @caption = { :style => val, :value => self.table_caption } unless @caption.kind_of?(Hash)
    @caption[:style] = val if @caption.kind_of?(Hash)
  end

  def table_caption=(val)
    @caption = val unless @caption.kind_of?(Hash)
    @caption[:value] = val if @caption.kind_of?(Hash)
  end

  def next_row()
    self.params << ""
    self.rows << []
  end

  def next_cell(type="td")
    if self.rows[-1].size == 0
      self.rows[-1] = [ { :type => type, :value => "", :style => "" } ]
    else
      self.rows[-1][-1][:value] = self.data
      self.rows[-1] << { :type => type, :value => "", :style => "" }
    end
  end

  def new_char()
    if @check_cell_data == 1
      case
      when current_char != '|' && @start_caption == false && self.rows[-1][-1][:style].blank?
        self.rows[-1][-1][:style] = self.data
        self.data = ""
      when current_char != '|' && @start_caption == true && self.table_caption_attributes.blank?
        self.table_caption_attributes = self.data
        self.data = ""
      end
      @check_cell_data = 0
    end

    case
    # Next table cell in row (TD)
    when current_char == "|" && (previous_char == "\n" || previous_char == "|") && @in_quotes == false
      self.data.chop!
      self.next_cell() unless self.data.blank? && previous_char == "|"
      self.data = ""

    # Next table cell in row (TH)
    when current_char == "!" && (previous_char == "\n" || previous_char == "!") && @in_quotes == false
      self.data.chop!
      self.next_cell('th')
      self.data = ""

    # End of a table
    when current_char == '}' && previous_char == '|'
      self.data = ""
      self.rows[-1].pop
      return false

    # Start table caption
    when current_char == '+' && previous_char == '|' && @in_quotes == false
      self.data = ""
      self.rows[-1].pop
      @start_caption = true

    # Table cell might have attributes
    when current_char == '|' && previous_char != "\n" && @in_quotes == false
      @check_cell_data = 1

    # End table caption
    when current_char == "\n" && @start_caption == true && @in_quotes == false
      @start_caption = false
      self.table_caption = self.data
      self.data = ""

    # in quotes
    when current_char == '"' && previous_char != '\\'
      @in_quotes = !@in_quotes
      self.data += '"'

    # Table params
    when current_char == "\n" && @start_table == true && @in_quotes == false
      @start_table = false
      unless self.data.blank?
        self.current_param = self.data
        self.params << ""
      end
      self.data = ""

    # Table row params
    when current_char == "\n" && @start_row == true && @in_quotes == false
      @start_row = false
      unless self.data.blank?
        self.current_param = self.data
      end
      self.data = ""

    # Start new table row
    when current_char == '-' && previous_char == '|' && @in_quotes == false
      self.data.chop!
      self.rows[-1].pop
      self.next_row()
      @start_row = true

    else
      self.data += current_char
    end

    return true
  end

end

end
