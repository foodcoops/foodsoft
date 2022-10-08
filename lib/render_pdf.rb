require 'prawn/measurement_extensions'

class RotatedCell < Prawn::Table::Cell::Text
  def initialize(pdf, text, options = {})
    options[:content] = text
    options[:valign] = :center
    options[:align] = :center
    options[:rotate_around] = :center
    @rotation = -options[:rotate] || 0
    super(pdf, [0, pdf.cursor], options)
  end

  def tan_rotation
    Math.tan(Math::PI * @rotation / 180)
  end

  def skew
    (height + (border_top_width / 2.0) + (border_bottom_width / 2.0)) / tan_rotation
  end

  def styled_width_of(text)
    options = @text_options.reject { |k| k == :style }
    with_font { (@pdf.height_of(@content, options) + padding_top + padding_bottom) / tan_rotation }
  end

  def natural_content_height
    options = @text_options.reject { |k| k == :style }
    with_font { (@pdf.width_of(@content, options) + padding_top + padding_bottom) * tan_rotation }
  end

  def draw_borders(pt)
    @pdf.mask(:line_width, :stroke_color) do
      x, y = pt
      from = [[x - skew, y + (border_top_width / 2.0)],
              to = [x, y - height - (border_bottom_width / 2.0)]]

      @pdf.line_width = @border_widths[3]
      @pdf.stroke_color = @border_colors[3]
      @pdf.stroke_line(from, to)
      @pdf.undash
    end
  end

  def draw_content
    with_font do
      with_text_color do
        text_box(width: spanned_content_width + FPTolerance + skew,
                 height: spanned_content_height + FPTolerance,
                 at: [1 - skew, @pdf.cursor]).render
      end
    end
  end
end

class RenderPDF < Prawn::Document
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  TOP_MARGIN = 36
  BOTTOM_MARGIN = 23
  HEADER_SPACE = 9
  FOOTER_SPACE = 3
  HEADER_FONT_SIZE = 16
  FOOTER_FONT_SIZE = 8
  DEFAULT_FONT = 'OpenSans'

  def initialize(options = {})
    options[:font_size] ||= FoodsoftConfig[:pdf_font_size].try(:to_f) || 12
    options[:page_size] ||= FoodsoftConfig[:pdf_page_size] || 'A4'
    options[:skip_page_creation] = true
    @options = options
    @first_page = true

    super(options)

    # Use ttf for better utf-8 compability
    font_families.update(
      'OpenSans' => {
        bold: font_path('OpenSans-Bold.ttf'),
        italic: font_path('OpenSans-Italic.ttf'),
        bold_italic: font_path('OpenSans-BoldItalic.ttf'),
        normal: font_path('OpenSans-Regular.ttf')
      }
    )

    header = options[:title] || title
    footer = I18n.l(Time.now, format: :long)

    header_size = 0
    header_size = height_of(header, size: HEADER_FONT_SIZE, font: DEFAULT_FONT) + HEADER_SPACE if header
    footer_size = height_of(footer, size: FOOTER_FONT_SIZE, font: DEFAULT_FONT) + FOOTER_SPACE

    start_new_page(top_margin: TOP_MARGIN + header_size, bottom_margin: BOTTOM_MARGIN + footer_size)

    font DEFAULT_FONT

    repeat :all, dynamic: true do
      bounding_box [bounds.left, bounds.top + header_size], width: bounds.width, height: header_size do
        text header, size: HEADER_FONT_SIZE, align: :center, overflow: :shrink_to_fit if header
      end
      font_size FOOTER_FONT_SIZE do
        bounding_box [bounds.left, bounds.bottom - FOOTER_SPACE], width: bounds.width, height: footer_size do
          text footer, align: :left, valign: :bottom
        end
        bounding_box [bounds.left, bounds.bottom - FOOTER_SPACE], width: bounds.width, height: footer_size do
          text I18n.t('lib.render_pdf.page', number: page_number, count: page_count), align: :right, valign: :bottom
        end
      end
    end
  end

  def title
    nil
  end

  def to_pdf
    body # Add content, which is defined in subclasses
    render # Render pdf
  end

  # Helper method to test pdf via rails console: OrderByGroups.new(order).save_tmp
  def save_tmp
    File.write("#{Rails.root}/tmp/#{self.class.to_s.underscore}.pdf", to_pdf.force_encoding("UTF-8"))
  end

  # @todo avoid underscore instead of unicode whitespace in pdf :/
  def number_to_currency(number, options = {})
    super(number, options).gsub("\u202f", ' ') if number
  end

  def font_size(points = nil, &block)
    points *= @options[:font_size] / 12 if points
    super(points, &block)
  end

  # add pagebreak or vertical whitespace, depending on configuration
  def down_or_page(space = 10)
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

  def fontsize(n)
    n
  end

  # return whether pagebreak or vertical whitespace is used for breaks
  def pdf_add_page_breaks?(docid = nil)
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

  def font_path(name)
    Rails.root.join('vendor', 'assets', 'fonts', name)
  end
end
