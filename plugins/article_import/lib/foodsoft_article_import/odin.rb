# frozen_string_literal: true

# Article import for De Nieuw Band XML file
#
# Always contains full assortment, including recently outlisted articles.
# To make sure we don't keep old articles when a number of updates was missed,
# +OUTLIST+ is set to +true+ to remove articles not present in the file.
#
require 'nokogiri'

module FoodsoftArticleImport
  class Odin
    NAME = 'De Nieuwe Band (XML)'
    OUTLIST = true
    OPTIONS = {}.freeze

    # parses a string or file
    def self.parse(file, custom_file_path: nil, **_opts)
      custom_file_path ||= nil
      xml = File.open(file)
      doc = Nokogiri.XML(xml, nil, nil,
                         Nokogiri::XML::ParseOptions::RECOVER +
                         Nokogiri::XML::ParseOptions::NONET +
                         Nokogiri::XML::ParseOptions::COMPACT) # do not modify doc!
      load_codes(custom_file_path)
      doc.search('product').each.with_index(1) do |row, i|
        # create a new article
        unit = row.search('eenheid').text
        unit = case unit.strip
               when '' then 'st'
               when 'stuk' then 'st'
               when 'g'    then 'gr' # need at least 2 chars
               when 'l'    then 'ltr'
               else             unit
               end
        inhoud = row.search('inhoud').text
        inhoud.to_s.strip.empty? or (inhoud.to_f - 1).abs > 1e-3 and unit = inhoud.gsub(/\.0+\s*$/, '') + unit
        deposit = row.search('statiegeld').text
        deposit.to_s.strip.empty? and deposit = 0
        category = [
          @@codes[:indeling][row.search('indeling').text.to_i],
          @@codes[:indeling][row.search('subindeling').text.to_i]
        ].compact.join(' - ')

        status = row.search('status').text == 'Actief' ? nil : :outlisted
        article = {}
        unless row.search('bestelnummer').text == ''
          article = { order_number: row.search('bestelnummer').text,
                      # :ean => row.search('eancode').text,
                      name: row.search('omschrijving').text,
                      note: row.search('kwaliteit').text,
                      manufacturer: row.search('merk').text,
                      origin: row.search('herkomst').text,
                      unit: unit,
                      price: row.search('prijs inkoopprijs').text,
                      unit_quantity: row.search('sve').text,
                      tax: row.search('btw').text,
                      deposit: deposit,
                      article_category: category }
        end
        yield article, status, i
      end
    end

    @@codes = {}

    def self.load_codes(custom_file_path = nil)
      @gem_lib = File.expand_path '..', __dir__
      dir = File.join @gem_lib, 'foodsoft_article_import'
      begin
        @@codes = YAML.safe_load(File.open(File.join(dir, 'dnb_codes.yml'))).symbolize_keys
        if custom_file_path
          custom_codes = YAML.safe_load(File.open(custom_file_path)).symbolize_keys
          custom_codes.each_key do |key|
            custom_codes[key] = custom_codes[key].merge @@codes[key] if @@codes.keys.include?(key)
            @@codes = @@codes.merge custom_codes
          end
        end
        @@codes
      rescue StandardError => e
        raise "Failed to load dnb_codes: #{dir}/dnb_codes.yml: #{e.message}"
      end
    end
  end
end
