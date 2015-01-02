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
    @first_page = true
  end

  def to_pdf
    font_size fontsize(12)

    # Define header
    repeat :all, dynamic: true do
      s = fontsize(8)
      # header
      bounding_box [bounds.left, bounds.top+s*2], width: bounds.width, height: s*1.2 do
        text title, size: s, align: :center if title
      end
      # footer
      bounding_box [bounds.left, bounds.bottom-s], width: bounds.width, height: s*1.2  do
        text I18n.t('lib.order_pdf.page', number: page_number, count: page_count), size: s, align: :right
      end
      bounding_box [bounds.left, bounds.bottom-s], width: bounds.width, height: s*1.2  do
        text I18n.l(Time.now, format: :long), size: s, align: :left
      end
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
    super(number, options).gsub("\u202f", ' ') if number
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
    if @first_page
      @first_page = false
      return
    end
    if pdf_add_page_breaks?
      start_new_page
    else
      move_down space
    end
  end

  protected

  # return whether pagebreak or vertical whitespace is used for breaks
  def pdf_add_page_breaks?(docid=nil)
    docid ||= self.class.name.underscore
    cfg = FoodsoftConfig[:pdf_add_page_breaks]
    if cfg.is_a? Array
      cfg.index(docid.to_s).any?
    elsif cfg.is_a? Hash
      cfg[docid.to_s]
    else
      cfg
    end
  end
end
