require 'csv'

class RenderCSV
  include ActionView::Helpers::NumberHelper

  def initialize(object, options={})
    @object = object
    @options = options
    # defaults to please Microsoft Excel ...
    @options[:col_sep] ||= FoodsoftConfig[:csv_col_sep] || ';'
    @options[:row_sep] ||= FoodsoftConfig[:csv_row_sep] if FoodsoftConfig[:csv_row_sep]
    @options[:encoding] ||= FoodsoftConfig[:csv_encoding] || 'ISO-8859-15'
  end

  def to_csv
    CSV.generate @options do |csv|
      if h = header
        csv << h
      end
      data {|d| csv << d}
    end
  end

  def header
    nil
  end

  def data
    yield []
  end

  # Helper method to test pdf via rails console: OrderCsv.new(order).save_tmp
  def save_tmp
    encoding = @options[:encoding] || 'UTF-8'
    File.open("#{Rails.root}/tmp/#{self.class.to_s.underscore}.csv", 'w') {|f| f.write(to_csv.force_encoding(encoding)) }
  end

  # XXX avoid encoding confusion when using unicode whitespace
  def number_to_currency(number, options={})
    super(number, options).gsub("\u202f", ' ')
  end
end
