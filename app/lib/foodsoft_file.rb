# Foodsoft-file import
class FoodsoftFile
  # parses a string from a foodsoft-file
  # returns two arrays with articles and outlisted_articles
  # the parsed article is a simple hash
  def self.parse(file, options = {})
    articles = []
    SpreadsheetFile.parse file, options do |row|
      next if row[2].blank?

      article = { availability: row[0]&.strip == I18n.t('simple_form.yes'),
                  order_number: row[1],
                  name: row[2],
                  supplier_order_unit: ArticleUnitsLib.get_code_for_unit_name(row[3]),
                  unit: row[4],
                  article_unit_ratios: FoodsoftFile.parse_ratios_cell(row[5]),
                  minimum_order_quantity: row[6],
                  billing_unit: ArticleUnitsLib.get_code_for_unit_name(row[7]),
                  group_order_granularity: row[8],
                  group_order_unit: ArticleUnitsLib.get_code_for_unit_name(row[9]),
                  price: row[10],
                  price_unit: ArticleUnitsLib.get_code_for_unit_name(row[11]),
                  tax: row[12],
                  deposit: (row[13].nil? ? '0' : row[13]),
                  note: row[14],
                  article_category: row[15],
                  origin: row[16],
                  manufacturer: row[17] }
      articles << article
    end

    articles
  end

  def self.parse_ratios_cell(ratios_cell)
    return [] if ratios_cell.blank?

    previous_quantity = nil
    ratios = ratios_cell.split(/(?<!\\), /).each_with_index.map do |ratio_str, index|
      md = ratio_str.gsub('\\\\', '\\').gsub('\\,', ',').match(/(?<quantity>[+-]?(?:[0-9]*[.])?[0-9]+) (?<unit_name>.*)/)
      quantity = md[:quantity].to_d
      calculated_quantity = previous_quantity.nil? ? quantity : quantity * previous_quantity
      previous_quantity = calculated_quantity
      {
        sort: index + 1,
        quantity: calculated_quantity,
        unit: ArticleUnitsLib.get_code_for_unit_name(md[:unit_name])
      }
    end

    ratios.reject { |ratio| ratio[:unit].nil? }
  end
end
