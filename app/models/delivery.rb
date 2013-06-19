class Delivery < ActiveRecord::Base

  belongs_to :supplier
  has_one :invoice
  has_many :stock_changes,
    :dependent => :destroy,
    :include => 'stock_article',
    :order => 'articles.name COLLATE NOCASE ASC'

  scope :recent, :order => 'created_at DESC', :limit => 10

  validates_presence_of :supplier_id, :delivered_on

  accepts_nested_attributes_for :stock_changes, :allow_destroy => :true

  def new_stock_changes=(stock_change_attributes)
    for attributes in stock_change_attributes
      stock_changes.build(attributes) unless attributes[:quantity].to_i == 0
    end
  end

  def includes_article?(article)
    self.stock_changes.map{|stock_change| stock_change.stock_article.id}.include? article.id
  end
  
end


