# encoding: utf-8
class Messagegroup < Group

  validates_uniqueness_of :name

  protected
end
