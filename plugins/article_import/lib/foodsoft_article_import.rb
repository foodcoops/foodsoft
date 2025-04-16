# frozen_string_literal: true

require 'digest/sha1'
require 'tempfile'
require 'csv'
require 'yaml'
require 'active_support/core_ext/hash/keys'
require_relative 'foodsoft_article_import/bioromeo'
require_relative 'foodsoft_article_import/bnn'
require_relative 'foodsoft_article_import/utf8_encoder'
require_relative 'foodsoft_article_import/odin'
require_relative 'foodsoft_article_import/foodsoft'
module FoodsoftArticleImport
  class ConversionFailedException < StandardError; end

  # return list of known file formats
  #   each file_format module has
  #   #name              return a human-readable file format name
  #   #outlist_unlisted  if returns true, unlisted articles are outlisted
  #   #detect            return a likelyhood (0-1) of being able to process
  #   #parse             parse the data
  #
  def self.file_formats
    @@file_formats ||= {
      'bnn' => FoodsoftArticleImport::Bnn,
      'foodsoft' => FoodsoftArticleImport::Foodsoft,
      'dnb_xml' => FoodsoftArticleImport::Odin,
      'odin' => FoodsoftArticleImport::Odin,
      'bioromeo' => FoodsoftArticleImport::Bioromeo
    }.freeze
  end

  # Parse file by type (one of {.file_formats})
  #
  # @param file [File, Tempfile]
  # @option opts [String] type file format (required) (see {.file_formats})
  # @return [File, Roo::Spreadsheet] file with encoding set if needed
  def self.parse(file, custom_file_path: nil, type: nil, &blk)
    custom_file_path ||= nil
    type ||= 'foodsoft'
    parser = file_formats[type]
    if block_given?
      parser.parse(file, custom_file_path: custom_file_path, &blk)
    else
      data = []
      parser.parse(file, custom_file_path: custom_file_path) { |a| data << a }
      data
    end
  end

  # Helper method to generate an article number for suppliers that do not have one
  def self.generate_number(article)
    # something unique, but not too unique
    s = "#{article[:name]}-#{article[:unit_quantity]}x#{article[:unit]}"
    s = s.downcase.gsub(/[^a-z0-9.]/, '')
    # prefix abbreviated sha1-hash with colon to indicate that it's a generated number
    article[:order_number] = ":#{Digest::SHA1.hexdigest(s)[-7..]}"
    article
  end

  # Helper method for opening a spreadsheet file
  #
  # @param file [File] file to open
  # @param filename [String, NilClass] optional filename for guessing the file format
  # @param encoding [String, NilClass] optional CSV encoding
  # @param col_sep [String, NilClass] optional column separator
  # @return [Roo::Spreadsheet]
  def self.open_spreadsheet(file, filename: nil, encoding: nil, col_sep: nil, liberal_parsing: nil)
    opts = { csv_options: {} }
    opts[:csv_options][:encoding] = encoding if encoding
    opts[:csv_options][:col_sep] = col_sep if col_sep
    opts[:csv_options][:liberal_parsing] = true if liberal_parsing
    opts[:extension] = File.extname(File.basename(filename)) if filename
    puts "
    " + "______________" + "
    " + "______________" + "
    " + "______ext________" + "
    " + "#{opts[:extension]}" + "
    " + "______________"+ "
    " + "______________"+ "
    " + "______________"
    begin
      Roo::Spreadsheet.open(file, **opts)
    rescue StandardError => e
      raise "Failed to parse foodsoft file. make sure file format is correct: #{e.message}"
    end
  end
end
