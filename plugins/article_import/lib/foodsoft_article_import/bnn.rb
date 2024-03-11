# frozen_string_literal: true

# Module for translation and parsing of BNN-files (www.n-bnn.de)
#
module FoodsoftArticleImport
  module Bnn
    @@codes = {}
    @@midgard = {}
    # Loads the codes_file config/bnn_codes.yml into the class variable @@codes
    def self.load_codes(custom_file_path = nil)
      @gem_lib = File.expand_path '..', __dir__
      dir = File.join @gem_lib, 'foodsoft_article_import'
      begin
        @@codes = YAML.safe_load(File.open(File.join(dir, 'bnn_codes.yml'))).symbolize_keys
        if custom_file_path
          custom_codes = YAML.safe_load(File.open(custom_file_path)).symbolize_keys
          custom_codes.each_key do |key|
            custom_codes[key] = custom_codes[key].merge @@codes[key] if @@codes.keys.include?(key)
            @@codes = @@codes.merge custom_codes
          end
        end
        @@midgard = YAML.safe_load(File.open(File.join(dir, 'midgard_codes.yml'))).symbolize_keys
      rescue StandardError => e
        raise "Failed to load bnn_codes: #{dir}/{bnn,midgard}_codes.yml: #{e.message}"
      end
    end

    $missing_bnn_codes = []

    # translates codes from BNN to foodsoft-code
    def self.translate(key, value)
      if @@codes[key][value]
        @@codes[key][value]
      elsif @@midgard[key]
        @@midgard[key][value]
      elsif !value.nil?
        $missing_bnn_codes << value
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
      CSV.foreach(file, { col_sep: col_sep, encoding: encoding, headers: true }).with_index(1) do |row, i|
        # check if the line is empty
        unless row[0] == '' || row[0].nil?
          article = {
            name: row[6],
            order_number: row[0],
            note: row[7],
            manufacturer: translate(:manufacturer, row[10]),
            origin: row[12],
            article_category: translate(:category, row[16]),
            unit: row[23],
            price: row[37],
            tax: translate(:tax, row[33]),
            unit_quantity: row[22]
          }
          # TODO: Complete deposit list....
          article.merge!(deposit: translate(:deposit, row[26])) if translate(:deposit, row[26])

          if !row[62].nil?
            # consider special prices
            article[:note] = "Sonderpreis: #{article[:price]} von #{row[62]} bis #{row[63]}"
            yield article, :special, i

            # Check now for article status, we only consider outlisted articles right now
            # N=neu, A=Änderung, X=ausgelistet, R=Restbestand,
            # V=vorübergehend ausgelistet, W=wiedergelistet
          elsif row[1] == 'X' || row[1] == 'V'
            yield article, :outlisted, i
          else
            yield article, nil, i
          end
        end
      end
    end
  end
end
