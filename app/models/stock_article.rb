# == Schema Information
# Schema version: 20090120184410
#
# Table name: articles
#
#  id                  :integer         not null, primary key
#  name                :string(255)     default(""), not null
#  supplier_id         :integer         default(0), not null
#  article_category_id :integer         default(0), not null
#  unit                :string(255)     default(""), not null
#  note                :string(255)
#  availability        :boolean         default(TRUE), not null
#  manufacturer        :string(255)
#  origin              :string(255)
#  shared_updated_on   :datetime
#  price               :decimal(, )
#  tax                 :float
#  deposit             :decimal(, )     default(0.0)
#  unit_quantity       :integer         default(1), not null
#  order_number        :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  quantity            :integer         default(0)
#  deleted_at          :datetime
#  type                :string(255)
#

class StockArticle < Article
  has_many :stock_changes

  named_scope :available, :conditions => "quantity > 0"

  before_destroy :check_quantity

  # Update the quantity of items in stock
  def update_quantity!
    update_attribute :quantity, stock_changes.collect(&:quantity).sum
  end

  # Check for unclosed orders and substract its ordered quantity
  def quantity_available(exclude_order = nil)
    available = quantity
    for order in Order.stockit.all(:conditions => "state = 'open' OR state = 'finished'")
      unless order == exclude_order
        order_article = order.order_articles.first(:conditions => {:article_id => id})
        available -= order_article.units_to_order if order_article
      end
    end
    available
  end

  protected

  def check_quantity
    raise "#{name} kann nicht gelöscht werden. Der Lagerbestand ist nicht null." unless quantity == 0
  end
end
