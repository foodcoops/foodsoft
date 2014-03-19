require "prawn/measurement_extensions"

class OrderPdf < Prawn::Document
  include ActionView::Helpers::NumberHelper

  def initialize(order, options = {})
    options[:page_size] ||= FoodsoftConfig[:pdf_page_size] || "A4"
    #options[:left_margin]   ||= 40
    #options[:right_margin]  ||= 40
    options[:top_margin]    ||= 50
    #options[:bottom_margin] ||= 40
    super(options)
    @order = order
    @options = options
  end

  def to_pdf
    font_size fontsize(12)

    # Define header
    repeat :all, dynamic: true do
      draw_text title, size: fontsize(10), style: :bold, at: [bounds.left, bounds.top+20] if title # Header
      draw_text I18n.t('lib.order_pdf.page', :number => page_number), size: fontsize(8), at: [bounds.left, bounds.bottom-10] # Footer
    end

    body  # Add content, which is defined in subclasses

    render  # Render pdf
  end

  # Helper method to test pdf via rails console: OrderByGroups.new(order).save_tmp
  def save_tmp
    File.open("#{Rails.root}/tmp/#{self.class.to_s.underscore}.pdf", 'w') {|f| f.write(to_pdf.force_encoding("UTF-8")) }
  end

  # XXX avoid underscore instead of unicode whitespace in pdf :/
  def number_to_currency(number, options={})
    super(number, options).gsub("\u202f", ' ')
  end

  # return fontsize after scaling it with any configured factor
  # please use this wherever you're setting a fontsize
  def fontsize(n)
    if FoodsoftConfig[:pdf_font_size]
      n * FoodsoftConfig[:pdf_font_size].to_f/12
    else
      n
    end
  end

  # add pagebreak or vertical whitespace, depending on configuration
  def down_or_page(space=10)
    if FoodsoftConfig[:pdf_add_page_breaks]
      start_new_page
    else
      move_down space
    end
  end
end
