module ExtendedString

  def blank?
    respond_to?(:empty?) ? empty? : !self
  end

  def to_slug
    self.gsub(/\W+/, '-').gsub(/^-+/,'').gsub(/-+$/,'').downcase
  end

  def auto_link
    url_check = Regexp.new( '(^|[\n ])([\w]+?://[\w]+[^ \"\r\n\t<]*)', Regexp::MULTILINE | Regexp::IGNORECASE )
    www_check = Regexp.new( '(^|[\n ])((www)\.[^ \"\t\n\r<]*)', Regexp::MULTILINE | Regexp::IGNORECASE )
    self.gsub!(url_check, '\1<a href="\2">\2</a>')
    self.gsub!(www_check, '\1<a href="http://\2">\2</a>')
    to_s
  end

  def dump()
    ret = to_s
    delete!(to_s)
    ret
  end

  def smart_split(char)
    ret = []
    tmp = ""
    inside = 0
    to_s.each_char do |x|
      if x == char && inside == 0
        ret << tmp
        tmp = ""
      else
        inside += 1 if x == "[" || x == "{" || x == "<"
        inside -= 1 if x == "]" || x == "}" || x == ">"
        tmp += x
      end
    end
    ret << tmp unless tmp.empty?
    ret
  end

end
