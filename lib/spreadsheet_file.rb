require 'roo'

class SpreadsheetFile
  def self.parse(file, options = {})
    filepath = file.is_a?(String) ? file : file.to_path
    filename = options.delete(:filename) || filepath
    fileext = File.extname(filename)
    options[:csv_options] = { col_sep: ';', encoding: 'utf-8' }.merge(options[:csv_options] || {})
    s = Roo::Spreadsheet.open(filepath, options.merge({ extension: fileext }))

    row_index = 1
    s.each do |row|
      if row_index == 1
        # @todo try to detect headers; for now using the index is ok
      else
        yield row, row_index
      end
      row_index += 1
    end
    row_index
  end
end
