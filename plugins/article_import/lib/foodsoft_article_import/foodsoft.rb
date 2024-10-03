# frozen_string_literal: true

# Module for Foodsoft-file import
# The Foodsoft-file is a CSV-file, with semicolon-separated columns, or ODS/XLS/XLSX

require 'roo'
require 'roo-xls'

module FoodsoftArticleImport
  module Foodsoft
    NAME = 'Foodsoft (CSV, ODS, XLS, XLSX)'
    OUTLIST = false
    OPTIONS = {
      encoding: 'UTF-8',
      col_sep: ';'
    }.freeze

    # Parses Foodsoft file
    # the yielded article is a simple hash
    def self.parse(file, custom_file_path: nil)
      custom_file_path ||= nil
      opts = OPTIONS.dup

      ss = FoodsoftArticleImport.open_spreadsheet(file, **opts)

      header_row = true
      ss.sheet(0).each.with_index(1) do |row, i|
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

        article = { order_number: row[1],
                    name: row[2],
                    note: row[3],
                    manufacturer: row[4],
                    origin: row[5],
                    unit: row[6],
                    price: row[7],
                    tax: row[8],
                    unit_quantity: row[10],
                    article_category: row[13] }
        article.merge!(deposit: row[9]) unless row[9].nil?
        FoodsoftArticleImport.generate_number(article) if article[:order_number].to_s.strip.empty?
        if row[6].nil? || row[7].nil? || row[8].nil?
          yield article, 'Error: unit, price and tax must be entered', i
        else
          yield article, (row[0] == 'x' ? :outlisted : nil), i
        end
      end
    end
  end
end
