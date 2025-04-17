# frozen_string_literal: true

# Module for import of BioRomeo products from their Excel sheet, from Aug 2014 onwards

require 'roo'
require 'roo-xls'

module FoodsoftArticleImport
  class Bioromeo
    NAME = 'BioRomeo (XLSX, XLS, CSV)'
    OUTLIST = true
    OPTIONS = {
      encoding: 'UTF-8',
      col_sep: ';'
    }.freeze

    RE_UNITS = /(kg|gr|gram|pond|st|stuks?|set|bos|bossen|bosjes?|bak|bakjes?|liter|ltr|[lL]\.|ml|bol|krop)(\s*\.)?/i.freeze
    RES_PARSE_UNIT_LIST = [
      /\b((per|a)\s*)?([0-9,.]+\s*x\s*[0-9,.]+\s*#{RE_UNITS})/i,                     # 1x5 kg
      /\b((per|a)\s*)?([0-9,.]+\s*#{RE_UNITS}\s+x\s*[0-9,.]+)/i,                     # 1kg x 5
      /\b((per|a)\s*)?(([0-9,.]+\s*,\s+)*[0-9,.]+\s+of\s+[0-9,.]+\s*#{RE_UNITS})/i,  # 1, 2 of 5 kg
      /\b((per|a)\s*)?([0-9,.]+\s*#{RE_UNITS})/i,                                    # 1kg
      /\b((per|a)\s*)?(#{RE_UNITS})/i                                                # kg
    ].freeze
    # first parse with dash separator at the end, fallback to less specific
    RES_PARSE_UNIT = RES_PARSE_UNIT_LIST.map { |r| /-\s*#{r}\s*$/ } +
                     RES_PARSE_UNIT_LIST.map { |r| /-\s+#{r}/ } +
                     RES_PARSE_UNIT_LIST.map { |r| /#{r}\s*$/ } +
                     RES_PARSE_UNIT_LIST.map { |r| /-#{r}/ }

    def self.parse(file, custom_file_path: nil) # rubocop:todo Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Lint/UnusedMethodArgument
      opts = OPTIONS.dup
      opts[:liberal_parsing] = true
      opts[:col_sep] = ','
      ss = FoodsoftArticleImport.open_spreadsheet(file, **opts)
      sheet = ss.sheet(0).parse(clean: true,
                                order_number: /Artnr./,
                                name: /Product/,
                                skal: /Skal$/,
                                demeter: /Demeter$/,
                                unit_price: /prijs\b.*\beenh/i,
                                pack_price: /prijs\b.*\bcolli/i,
                                comment: /opm(erking)?/i)

      linenum = 0
      category = nil

      sheet.each do |row| # rubocop:todo Metrics/BlockLength
        linenum += 1
        row[:name].to_s.strip.empty? and next
        # (sub)categories are in first two content cells - assume if there's a price it's a product
        if row[:order_number].to_s.strip.empty? && row[:unit_price].to_s.strip.empty?
          category = row[:name]
          yield nil, nil, linenum
          next
        end
        # skip products without a number
        if row[:order_number].to_s.strip.empty?
          yield nil, nil, linenum
          next
        end
        # extract name and unit
        errors = []
        notes = []
        unit_price = row[:unit_price].gsub('€', '').to_s.strip.to_f
        pack_price = row[:pack_price].gsub('€', '').to_s.strip.to_f
        number = row[:order_number]
        name = row[:name]
        unit = nil
        manufacturer = nil
        prod_category = nil
        RES_PARSE_UNIT.each do |re|
          m = name.match(re)
          unless m
            yield nil, nil, linenum
            next
          end
          unit = normalize_unit(m[3])
          name = name.sub(re, '').sub(/\(\s*\)\s*$/, '').sub(/\s+/, ' ').sub(/\.\s*$/, '').strip
          break
        end
        unit ||= '1 st' if name.match(/\bsla\b/i)
        unit ||= '1 bos' if name.match(/\bradijs\b/i)
        unit ||= '1 bosje' if category.match(/\bkruid/i)
        if unit.nil?
          unit = '?'
          errors << "Cannot find unit in name '#{name}'"
        end
        # handle multiple units in one line
        if unit.match(/\b(,\s+|of)\b/)
          # TODO: create multiple articles instead of taking first one
        end
        # sometimes category is also used to indicate manufacturer
        m = category.match(/((eko\s*)?boerderij.*?)\s*$/i) and manufacturer = m[1]
        # Ad-hoc fix for package of eggs: always take pack price
        if name.match(/^eieren/i)
          unit_price = pack_price
          prod_category = 'Eieren'
        end
        prod_category = 'Kaas' if name.match(/^kaas/i)
        # figure out unit_quantity
        if unit.match(/x/)
          unit_quantity, unit = unit.split(/\s*x\s*/i, 2)
          unit, unit_quantity = unit_quantity, unit if unit_quantity.match(/[a-z]/i)
        elsif (unit_price - pack_price).abs < 1e-3
          unit_quantity = 1
        elsif (m = unit.match(/^(.*)\b\s*(st|bos|bossen|bosjes?)\.?\s*$/i))
          unit_quantity, unit = m[1..2]
          unit_quantity.blank? and unit_quantity = 1
        else # rubocop:todo Lint/DuplicateBranch
          unit_quantity = 1
        end
        # there may be a more informative unit in the line
        if unit == 'st' && !name.match(/kool/i)
          RES_PARSE_UNIT.each do |re|
            m = name.match(re) or next
            unit = normalize_unit(m[3])
            name = name.sub(re, '').strip
          end
        end
        # NOTE: from various fields
        notes.append("Skal #{row[:skal]}") unless row[:skal].to_s.strip.empty?
        notes.append(row[:demeter]) unless row[:skal].to_s.strip.empty?
        notes.append("Demeter #{row[:demeter]}") unless row[:skal].to_s.strip.empty? && row[:demeter].is_a?(Integer)
        notes.append "(#{row[:comment]})" unless row[:comment].to_s.strip.empty?
        name.sub!(/(,\.?\s*)?\bDemeter\b/i, '') and notes.prepend('Demeter')
        name.sub!(/(,\.?\s*)?\bBIO\b/i, '') and notes.prepend 'BIO'
        # unit check
        errors << check_price(unit, unit_quantity, unit_price, pack_price)
        # create new article
        name.gsub!(/\s+/, ' ')
        article = { order_number: number,
                    name: name.strip,
                    note: notes.count.positive? && notes.map(&:strip).join('; '),
                    manufacturer: manufacturer,
                    origin: 'Noordoostpolder, NL',
                    unit: unit,
                    price: pack_price.to_f / unit_quantity,
                    unit_quantity: unit_quantity,
                    tax: 6,
                    deposit: 0,
                    article_category: prod_category || category }
        errors.compact!
        if errors.count.positive?
          yield article, errors.join("\n"), linenum
        else
          # outlisting not used by supplier
          yield article, nil, linenum
        end
      end
    end

    def self.check_price(unit, unit_quantity, unit_price, pack_price)
      if (unit_price - pack_price).abs < 1e-3
        return if unit_quantity == 1

        return "price per unit #{unit_price} is pack price, but unit quantity #{unit_quantity} is not one"
      end

      return "could not parse unit: #{unit}" unless (m = unit.match(/^(.*)(#{RE_UNITS})\s*$/))

      amount, what = m[1..2]

      # perhaps unit price is kg-price
      kgprice = case what
                when /^kg/i
                  pack_price.to_f / amount.to_f # rubocop:todo Style/FloatDivision
                when /^gr/
                  pack_price.to_f / amount.to_f * 1000 # rubocop:todo Style/FloatDivision
                end
      return unless kgprice.to_s.strip.empty? && (kgprice - unit_price.to_f).abs < 1e-2

      unit_price_computed = pack_price.to_f / unit_quantity.to_i
      return unless (unit_price_computed - unit_price.to_f).abs > 1e-2

      "price per unit given #{unit_price.round(3)} does not match computed " \
      "#{pack_price.round(3)}/#{unit_quantity}=#{unit_price_computed.round(3)}" +
        (kgprice ? " (nor is it a kg-price #{kgprice.round(3)})" : '')
    end

    def self.normalize_unit(unit)
      unit = unit.sub(/1\s*x\s*/, '')
      unit = unit.sub(/,([0-9])/, '.\1').gsub(/^per\s*/, '').sub(/^1\s*([^0-9.])/, '\1').sub(/^a\b\s*/, '')
      unit = unit.sub(/(bossen|bosjes?)/, 'bos').sub(/(liter|l\.|L\.)/, 'ltr').sub(/stuks?/, 'st').sub('gram', 'gr')
      unit.sub(/\s*\.\s*$/, '').sub(/\s+/, ' ').strip
    end
  end
end
