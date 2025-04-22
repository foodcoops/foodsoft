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
      # header detection must be done by using code (e.g. based on index)
      yield row, row_index
      row_index += 1
    end
    row_index
  end
end
