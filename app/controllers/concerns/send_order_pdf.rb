module Concerns::SendOrderPdf
  extend ActiveSupport::Concern

  protected

  def send_order_pdf order, document
    klass = case document
            when 'groups'   then OrderByGroups
            when 'articles' then OrderByArticles
            when 'fax'      then OrderFax
            when 'matrix'   then OrderMatrix
            end
    pdf = klass.new order
    send_data pdf.to_pdf, filename: pdf.filename, type: 'application/pdf'
  end
end
