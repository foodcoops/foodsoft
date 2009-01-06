class Document < ActiveRecord::Base
  acts_as_ordered
end

class Entry < Document
end

class Page < Document
end
