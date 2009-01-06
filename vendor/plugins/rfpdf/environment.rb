begin
  require('htmlentities') 
rescue LoadError
  # This gem is not required - just nice to have.
end
require('cgi')

require "#{File.dirname __FILE__}/lib/core/view"
require "#{File.dirname __FILE__}/lib/core/rfpdf"

require "#{File.dirname __FILE__}/lib/tcpdf"

require "#{File.dirname __FILE__}/lib/fpdf/errors"
require "#{File.dirname __FILE__}/lib/fpdf/fpdf"
require "#{File.dirname __FILE__}/lib/fpdf/chinese"
require "#{File.dirname __FILE__}/lib/fpdf/japanese"
require "#{File.dirname __FILE__}/lib/fpdf/korean"

ActionView::Template::register_template_handler 'rfpdf', RFPDF::View