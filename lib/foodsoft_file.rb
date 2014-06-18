# Module for Foodsoft-File import
# The Foodsoft-File is a cvs-file, with columns separated by semicolons

require 'csv'

module FoodsoftFile
  
  # parses a string from a foodsoft-file
  # returns two arrays with articles and outlisted_articles
  # the parsed article is a simple hash
  def self.parse(file)
    articles, outlisted_articles = Array.new, Array.new
    row_index = 2
    ::CSV.parse(file.read.force_encoding('utf-8'), {:col_sep => ";", :headers => true}) do |row|
      # check if the line is empty
      unless row[2] == "" || row[2].nil?        
        article = {:number => row[1],
                   :name => row[2],
                   :note => row[3],
                   :manufacturer => row[4],
                   :origin => row[5],
                   :unit => row[6],
                   :price => row[7],
                   :tax => row[8],
                   :deposit => (row[9].nil? ? "0" : row[9]),
                   :unit_quantity => row[10],
                   :scale_quantity => row[11],
                   :scale_price => row[12],
                   :category => row[13]}
        case row[0]
        when "x"
          # check if the article is outlisted
          outlisted_articles << article
        else
          articles << article
        end
      end
      row_index += 1
    end
    return [articles, outlisted_articles]
  end
    
end
