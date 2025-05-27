##
# Export order as "Biofakt B85 Mailbox Order Format"
# https://n-bnn.de/leistungen-services/markt-und-produktdaten/schnittstelle
# See also files in doc/formats/b85.
#
# This format is used by German organic wholesalers for remote ordering via FTP.
#
# Relevant parts of the format specification from the year 1996:
# - ASCII-based format, e.g. ISO-8859-1 encoding
# - A dataset is closed with CR/LF (0Dh/0Ah)
# - The end of the file is marked with EoF (1Ah, not present in example)
# - First dataset starts with "D#" (identification) followed by
#   - 6 digits customer number
#   - 6 digits delivery date (yymmdd, "000000" means "next tour")
#   - 1 digit empty (space) or "A" ("A" means "will be collected")
#   - optional: 6 digits customer order number
# - From second dataset on follow article sets:
#   - 13 digits article number, left-aligned followed by spaces
#   - 1 digit sign for order quantity ("+" means "order")
#   - 7 digits quantity in packaging units (4 digits integer part, 3 digits fractional part)
#   - 30 digits article description
#   - 7 digits packaging quantity (4 digits integer part, 3 digits fractional part)
#   - target: 12 digits packaging text (used for two-digit unit identifier in example)
#   - optional: 3 digits producer abbreviation
#   - optional: 4 digits quality abbreviation
#   - optional: 3 digits country of origin
#   - optional: 13 digits customer article number
#   - optional: 6 digits unit price per piece (4 digits integer part, 2 digits fractional part)
# - Target and optional fields are only taken into account if the article number is not found
# - Text additions possible as a separate dataset:
#   - 13 digits:
#     - empty (space) for header or footer text
#     - article number as line before for article related text
#   - 8 digits empty (space)
#   - 78 digits for text (e.g. order comment)

class OrderB85
  def initialize(order, _options = {})
    @order = order
  end

  def to_b85
    b85 = header + end_of_dataset
    b85 += data.join(end_of_dataset)
    b85 += end_of_dataset
    b85.encode('ISO-8859-1')
  end

  private

  def header
    # validation takes place in Supplier
    customer_number = @order.supplier.customer_number || ''
    [
      # identification
      'D#',
      # customer number (validation takes place in Supplier)
      format('%06i', customer_number[0, 6].to_i),
      # delivery date: we might want to use @order.pickup
      '000000',
      # delivery
      ' '
      # optional: we might want to add foodsoft order number
    ].join
  end

  def data
    order_articles = @order.order_articles.ordered.includes(:article_version)
    order_articles.map do |article|
      unit_ratio = article.article_version.article_unit_ratios.first
      # validation takes place in OrderArticle
      order_quantity = article.units_to_order < 10_000 ? article.units_to_order : 0
      packaging_quantity = unit_ratio.quantity < 10_000 ? unit_ratio.quantity : 0
      [
        # article number (validation takes place in OrderArticle)
        article.article_version.order_number[0, 13].ljust(13),
        # sign for order quantity
        '+',
        # order quantity (in packaging units)
        format('%08.3f', order_quantity).delete('.'),
        # article description
        article.article_version.name[0, 30].ljust(30),
        # packaging quantity
        format('%08.3f', packaging_quantity).delete('.'),
        # packaging text (used for unit name)
        ArticleUnitsLib.get_translated_name_for_code(unit_ratio.unit)[0, 12].ljust(12)
        # optional fields might be added
      ].join
    end
  end

  def end_of_dataset
    "\r\n"
  end
end
