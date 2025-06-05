# frozen_string_literal: true

# Module for translation and parsing of BNN-files
# https://n-bnn.de/leistungen-services/markt-und-produktdaten/schnittstelle
# (German specs are included in doc/formats/bnn)
#
module FoodsoftArticleImport
  module Bnn
    @@codes = {} # rubocop:todo Style/ClassVars
    @@midgard = {} # rubocop:todo Style/ClassVars
    # Loads the codes_file config/bnn_codes.yml into the class variable @@codes
    def self.load_codes(custom_file_path = nil)
      @gem_lib = File.expand_path '..', __dir__
      dir = File.join @gem_lib, 'foodsoft_article_import'
      begin
        @@codes = YAML.safe_load(File.open(File.join(dir, 'bnn_codes.yml'))).symbolize_keys # rubocop:todo Style/ClassVars
        if custom_file_path
          custom_codes = YAML.safe_load(File.open(custom_file_path)).symbolize_keys
          custom_codes.each_key do |key|
            custom_codes[key] = custom_codes[key].merge @@codes[key] if @@codes.keys.include?(key)
            @@codes = @@codes.merge custom_codes # rubocop:todo Style/ClassVars
          end
        end
        @@midgard = YAML.safe_load(File.open(File.join(dir, 'midgard_codes.yml'))).symbolize_keys # rubocop:todo Style/ClassVars
      rescue StandardError => e
        raise "Failed to load bnn_codes: #{dir}/{bnn,midgard}_codes.yml: #{e.message}"
      end
    end

    $missing_bnn_codes = [] # rubocop:todo Style/GlobalVars

    # translates codes from BNN to foodsoft-code
    def self.translate(key, value)
      if @@codes[key][value]
        @@codes[key][value]
      elsif @@midgard[key]
        @@midgard[key][value]
      elsif !value.nil?
        $missing_bnn_codes << value # rubocop:todo Style/GlobalVars
        nil
      end
    end

    NAME = 'BNN (CSV)'
    OUTLIST = false
    OPTIONS = {
      encoding: 'IBM850',
      col_sep: ';'
    }.freeze

    # parses a bnn-file
    def self.parse(file, custom_file_path: nil, **opts)
      custom_file_path ||= nil
      encoding = opts[:encoding] || OPTIONS[:encoding]
      col_sep = opts[:col_sep] || OPTIONS[:col_sep]
      load_codes(custom_file_path)
      piece_unit_code = 'XPP'
      CSV.foreach(file, { col_sep: col_sep, encoding: encoding, headers: true }).with_index(1) do |row, i|
        # check if the line is empty
        unless row[0] == '' || row[0].nil?
          article = {
            availability: %w[X V].exclude?(row[1]),
            name: UTF8Encoder.clean(row[6]),
            order_number: row[0],
            unit: row[21],
            article_unit_ratios: [{ sort: 1, quantity: row[22], unit: piece_unit_code }],
            minimum_order_quantity: row[20],
            group_order_granularity: 1,
            billing_unit: piece_unit_code,
            group_order_unit: piece_unit_code,
            supplier_order_unit: nil,
            price: row[37],
            price_unit: piece_unit_code,
            note: UTF8Encoder.clean(row[7]),
            manufacturer: translate(:manufacturer, row[10]),
            origin: row[12],
            article_category: translate(:category, row[16]),
            tax: translate(:tax, row[33])
          }

          # TODO: Complete deposit list....
          article.merge!(deposit: translate(:deposit, row[26])) if translate(:deposit, row[26])

          if row[62].nil?
            yield article, (article[:availability] ? nil : :outlisted), i
          else
            # consider special prices
            article[:note] = "Sonderpreis: #{article[:price]} von #{row[62]} bis #{row[63]}"
            yield article, :special, i
          end
        end
      end
    end
  end
end
