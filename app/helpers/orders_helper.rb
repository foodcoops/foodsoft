module OrdersHelper
  require 'iconv'

  # This method is needed to convert special characters into UTF-8 for rendering PDF files correctly.
  def replace_UTF8(field)
    ic_ignore = Iconv.new('ISO-8859-15//IGNORE//TRANSLIT', 'UTF-8')
    field = ic_ignore.iconv(field)
    ic_ignore.close  
    field
  end
end
