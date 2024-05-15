require 'csv'

class RenderCsv
  include ActionView::Helpers::NumberHelper

  def initialize(object, options = {})
    @object = object
    @options = options
    # defaults to please Microsoft Excel ...
    @options[:col_sep] ||= FoodsoftConfig[:csv_col_sep] || ';'
    @options[:row_sep] ||= FoodsoftConfig[:csv_row_sep] if FoodsoftConfig[:csv_row_sep]
    @options[:encoding] ||= FoodsoftConfig[:csv_encoding] || 'ISO-8859-15'
  end

  def to_csv
    options = @options.select { |k| %w[col_sep row_sep].include? k.to_s }
    ret = CSV.generate options do |csv|
      if h = header
        csv << h
      end
      data { |d| csv << d }
    end
    ret << I18n.t('.orders.articles.prices_sum') << ";" << "#{number_to_currency(@object.sum(:gross))}/#{number_to_currency(@object.sum(:net))}" if @options[:custom_csv]
    ret.encode(@options[:encoding], invalid: :replace, undef: :replace)
  end

  def header
    nil
  end

  def data
    yield []
  end

  # XXX disable unit to avoid encoding problems, both in unit and whitespace. Also allows computations in spreadsheet.
  def number_to_currency(number, options = {})
    super(number, options.merge({ unit: '' }))
  end
end
