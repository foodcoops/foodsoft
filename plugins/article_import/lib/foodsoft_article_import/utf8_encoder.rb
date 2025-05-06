# frozen_string_literal: true

module UTF8Encoder
  def self.clean(string)
    if string.nil?
      string
    else
      string.encode('UTF-8')
    end
  end
end
