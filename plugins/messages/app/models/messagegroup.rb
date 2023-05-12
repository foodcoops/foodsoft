class Messagegroup < Group
  validates_uniqueness_of :name
end
