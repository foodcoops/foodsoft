require 'roo'

# Foodsoft-file import
class FoodsoftFile

  # parses a string from a foodsoft-file
  # returns two arrays with articles and outlisted_articles
  # the parsed article is a simple hash
  def self.parse(file, options = {})
    filepath = file.is_a?(String) ? file : file.to_path
    filename = options.delete(:filename) || filepath
    fileext = File.extname(filename)
    options[:csv_options] = {col_sep: ';', encoding: 'utf-8'}.merge(options[:csv_options]||{})
    s = Roo::Spreadsheet.open(filepath, options.merge({extension: fileext}))

    row_index = 1
    s.each do |row|
      if row_index == 1
        # @todo try to detect headers; for now using the index is ok

      elsif !row[2].blank?
        article = {:order_number => row[1],
                   :name => row[2],
                   :note => row[3],
                   :manufacturer => row[4],
                   :origin => row[5],
                   :unit => row[6],
                   :price => row[7],
                   :tax => row[8],
                   :deposit => (row[9].nil? ? "0" : row[9]),
                   :unit_quantity => row[10],
                   :article_category => row[13]}
        status = row[0] && row[0].strip.downcase == 'x' ? :outlisted : nil
        yield status, article, row_index
      end
      row_index += 1
    end
    row_index
  end

end
