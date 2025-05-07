# frozen_string_literal: true

# Module for Foodsoft-file import
# The Foodsoft-file is a CSV-file, with semicolon-separated columns, or ODS/XLS/XLSX

require 'roo'
require 'roo-xls'

module FoodsoftArticleImport
  module FoodsoftSpreadsheet
    NAME = 'Foodsoft (CSV, ODS, XLS, XLSX)'
    OUTLIST = false
    OPTIONS = {
      encoding: 'UTF-8',
      col_sep: ';'
    }.freeze

    # Parses Foodsoft file
    # the yielded article is a simple hash
    def self.parse(file, options = {})
      opts = OPTIONS.dup

      ss = FoodsoftArticleImport.open_spreadsheet(file, **opts)

      header_row = true
      foodsoft_url = nil
      ss.sheet(0).each.with_index(1) do |row, i|
        foodsoft_url = row[18] if header_row
        # skip first header row
        if header_row
          header_row = false
          next
        end
        # skip empty lines
        if row[2].to_s.strip.empty?
          # raise no order number given
          yield nil, nil, i
          next
        end

        article = { availability: row[0]&.strip == I18n.t('simple_form.yes'),
                    order_number: row[1],
                    name: row[2],
                    supplier_order_unit: ArticleUnitsLib.get_code_for_unit_name(row[3]),
                    unit: row[4],
                    article_unit_ratios: parse_ratios_cell(row[5]),
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
        article[:id] = row[18] unless foodsoft_url.blank? || foodsoft_url != options[:foodsoft_url]
        FoodsoftArticleImport.generate_number(article) if article[:order_number].to_s.strip.empty?
        yield article, (article[:availability] ? :outlisted : nil), i
      end
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
end
