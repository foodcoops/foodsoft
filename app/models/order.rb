# == Schema Information
# Schema version: 20090119155930
#
# Table name: orders
#
#  id                 :integer         not null, primary key
#  supplier_id        :integer
#  note               :text
#  starts             :datetime
#  ends               :datetime
#  state              :string(255)     default("open")
#  lock_version       :integer         default(0), not null
#  updated_by_user_id :integer
#

class Order < ActiveRecord::Base
  extend ActiveSupport::Memoizable    # Ability to cache method results. Use memoize :expensive_method
  acts_as_ordered :order => "ends"    # easyier find of next or previous model

  # Associations
  has_many :order_articles, :dependent => :destroy
  has_many :articles, :through => :order_articles
  has_many :group_orders, :dependent => :destroy
  has_many :ordergroups, :through => :group_orders
  has_one :invoice
  has_many :comments, :class_name => "OrderComment", :order => "created_at"
  has_many :stock_changes
  belongs_to :supplier
  belongs_to :updated_by, :class_name => "User", :foreign_key => "updated_by_user_id"

  # Validations
  validates_presence_of :starts
  validate :starts_before_ends, :include_articles

  # Callbacks
  after_update :update_price_of_group_orders
 
  # Finders
  named_scope :open, :conditions => {:state => 'open'}, :order => 'ends DESC'
  named_scope :finished, :conditions => "state = 'finished' OR state = 'closed'", :order => 'ends DESC'
  named_scope :finished_not_closed, :conditions => {:state => 'finished'}, :order => 'ends DESC'
  named_scope :closed, :conditions => {:state => 'closed'}, :order => 'ends DESC'
  named_scope :stockit, :conditions => {:supplier_id => 0}, :order => 'ends DESC'

  def stockit?
    supplier_id == 0
  end

  def name
    stockit? ? "Lager" : supplier.name
  end

  def articles_for_ordering
     if stockit?
       StockArticle.available.all(:include => :article_category,
         :order => 'article_categories.name, articles.name').reject{ |a|
         a.quantity_available == 0
         }.group_by { |a| a.article_category.name }
     else
       supplier.articles.available.all.group_by { |a| a.article_category.name }
     end
  end

  # Fetch last orders from same supplier, to generate an article selection proposal
  def templates
    if stockit?
      Order.stockit :limit => 5
    else
      supplier.orders.finished :limit => 5
    end
  end

  # Create or destroy OrderArticle associations on create/update
  def article_ids=(ids)
    # fetch selected articles
    articles_list = Article.find(ids)
    # create new order_articles
    (articles_list - articles).each { |article| order_articles.build(:article => article) }
    # delete old order_articles
    articles.reject { |article| articles_list.include?(article) }.each do |article|
      order_articles.detect { |order_article| order_article.article_id == article.id }.destroy
    end
  end

  def open?
    state == "open"
  end

  def finished?
    state == "finished"
  end

  def closed?
    state == "closed"
  end

  # search GroupOrder of given Ordergroup
  def group_order(ordergroup)
    group_orders.first :conditions => { :ordergroup_id => ordergroup.id }
  end
 
  # Returns OrderArticles in a nested Array, grouped by category and ordered by article name.
  # The array has the following form:
  # e.g: [["drugs",[teethpaste, toiletpaper]], ["fruits" => [apple, banana, lemon]]]
  def articles_grouped_by_category
    order_articles.all(:include => [:article, :article_price], :order => 'articles.name').group_by { |a|
      a.article.article_category.name
    }.sort { |a, b| a[0] <=> b[0] }
  end
  memoize :articles_grouped_by_category

  def articles_sort_by_category
    order_articles.all(:include => [:article], :order => 'articles.name').sort do |a,b|
      a.article.article_category.name <=> b.article.article_category.name
    end
  end
  
  # Returns the defecit/benefit for the foodcoop
  # Requires a valid invoice, belonging to this order
  def profit(options = {})
    markup = options[:with_markup] || true
    if invoice
      groups_sum = markup ? sum(:groups) : sum(:groups_without_markup)
      groups_sum - invoice.net_amount
    end
  end
  
  # Returns the all round price of a finished order
  # :groups returns the sum of all GroupOrders
  # :clear returns the price without tax, deposit and markup
  # :gross includes tax and deposit. this amount should be equal to suppliers bill
  # :fc, guess what...
  def sum(type = :gross)
    total = 0
    if type == :net || type == :gross || type == :fc
      for oa in order_articles.ordered.all(:include => [:article,:article_price])
        quantity = oa.units_to_order * oa.price.unit_quantity
        case type
        when :net
          total += quantity * oa.price.price
        when :gross
          total += quantity * oa.price.gross_price
        when :fc
          total += quantity * oa.price.fc_price
        end
      end
    elsif type == :groups || type == :groups_without_markup
      for go in group_orders
        for goa in go.group_order_articles
          case type
          when :groups
            total += goa.result * goa.order_article.price.fc_price
          when :groups_without_markup
            total += goa.result * goa.order_article.price.gross_price
          end
        end
      end
    end
    total
  end

  # Finishes this order. This will set the order state to "finish" and the end property to the current time.
  # Ignored if the order is already finished.
  def finish!(user)
    unless finished?
      Order.transaction do
        # Update order_articles. Save the current article_price to keep price consistency
        # Also save results for each group_order_result
        order_articles.all(:include => :article).each do |oa|
          oa.update_attribute(:article_price, oa.article.article_prices.first)
          oa.group_order_articles.each { |goa| goa.save_results! }
        end
        # set new order state (needed by notify_order_finished)
        update_attributes(:state => 'finished', :ends => Time.now, :updated_by => user)

        # Clean up
        # Delete no longer required order-history (group_order_article_quantities) and
        # TODO: Do we need articles, which aren't ordered? (units_to_order == 0 ?)
        order_articles.each do |oa|
          oa.group_order_articles.each { |goa| goa.group_order_article_quantities.clear }
        end
      end

      # notify order groups
      notify_order_finished
    end
  end
  
  # Sets order.status to 'close' and updates all Ordergroup.account_balances
  def close!(user)
    raise "Bestellung wurde schon abgerechnet" if closed?
    transaction_note = "Bestellung: #{name}, bis #{ends.strftime('%d.%m.%Y')}"

    gos = group_orders.all(:include => :ordergroup)       # Fetch group_orders
    gos.each { |group_order| group_order.update_price! }  # Update prices of group_orders

    transaction do                                        # Start updating account balances
      for group_order in gos
        price = group_order.price * -1                    # decrease! account balance
        group_order.ordergroup.add_financial_transaction(price, transaction_note, user)
      end

      if stockit?                                         # Decreases the quantity of stock_articles
        for oa in order_articles.all(:include => :article)
          oa.update_results!                              # Update units_to_order of order_article
          stock_changes.create! :stock_article => oa.article, :quantity => oa.units_to_order*-1
        end
      end

      self.update_attributes! :state => 'closed', :updated_by => user
    end
  end
  
  protected

  def starts_before_ends
     errors.add(:ends, "muss nach dem Bestellstart liegen (oder leer bleiben)") if (ends && starts && ends <= starts)
  end

  def include_articles
    errors.add(:order_articles, "Es muss mindestens ein Artikel ausgewählt sein") if order_articles.empty?
  end

  private
  
  # Updates the "price" attribute of GroupOrders or GroupOrderResults
  # This will be either the maximum value of a current order or the actual order value of a finished order.
  def update_price_of_group_orders
    group_orders.each { |group_order| group_order.update_price! }
  end

  # Sends "order finished" messages to users who have participated in this order.
  def notify_order_finished
    for group_order in self.group_orders
      ordergroup = group_order.ordergroup
      logger.debug("Send 'order finished' message to #{ordergroup.name}")
      # Determine users that want a notification message:
      users = ordergroup.users.reject{|u| u.settings["notify.orderFinished"] != '1'}
      unless users.empty?
        # Create user notification messages:
        Message.from_template(
          'order_finished',
          {:group => ordergroup, :order => self, :group_order => group_order},
          {:recipients_ids => users.collect(&:id), :subject => "Bestellung beendet: #{supplier.name}"}
        ).save!
      end
    end
  end

end
