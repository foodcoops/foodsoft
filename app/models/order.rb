# == Schema Information
# Schema version: 20090102171850
#
# Table name: orders
#
#  id                 :integer(4)      not null, primary key
#  name               :string(255)     default(""), not null
#  supplier_id        :integer(4)      default(0), not null
#  starts             :datetime        not null
#  ends               :datetime
#  note               :string(255)
#  finished           :boolean(1)      not null
#  booked             :boolean(1)      not null
#  lock_version       :integer(4)      default(0), not null
#  updated_by_user_id :integer(4)
#  invoice_amount     :decimal(8, 2)   default(0.0), not null
#  deposit            :decimal(8, 2)   default(0.0)
#  deposit_credit     :decimal(8, 2)   default(0.0)
#  invoice_number     :string(255)
#  invoice_date       :string(255)
#

class Order < ActiveRecord::Base
  has_many :order_articles, :dependent => :destroy
  has_many :articles, :through => :order_articles
  has_many :group_orders, :dependent => :destroy
  has_many :order_groups, :through => :group_orders
  has_many :order_article_results, :dependent => :destroy
  has_many :group_order_results, :dependent => :destroy
  belongs_to :supplier
  belongs_to :updated_by, :class_name => "User", :foreign_key => "updated_by_user_id"

  validates_length_of :name, :in => 2..50
  validates_presence_of :starts
  validates_presence_of :supplier_id
  validates_inclusion_of :finished, :in => [true, false]
  validates_numericality_of :invoice_amount, :deposit, :deposit_credit
  
  validate_on_create :include_articles
  
#  attr_accessible :name, :supplier, :starts, :ends, :note, :invoice_amount, :deposit, :deposit_credit, :invoice_number, :invoice_date
  
  #use plugin to make Order commentable
  acts_as_commentable

  # easyier find of next or previous model
  acts_as_ordered :order => "ends"
  
  # Custom attribute setter that accepts decimal numbers using localized decimal separator.
  def invoice_amount=(amount)
    self[:invoice_amount] = String.delocalized_decimal(amount)
  end
  
  # Custom attribute setter that accepts decimal numbers using localized decimal separator.
  def deposit=(deposit)
    self[:deposit] = String.delocalized_decimal(deposit)
  end
  
  # Custom attribute setter that accepts decimal numbers using localized decimal separator.
  def deposit_credit=(deposit)
    self[:deposit_credit] = String.delocalized_decimal(deposit)
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
  
  # Returns all current orders, i.e. orders that are not finished and the current time is between the order's start and end time.
  def self.find_current
    find(:all, :conditions => ['finished = ? AND starts < ? AND (ends IS NULL OR ends > ?)', false, Time.now, Time.now], :order => 'ends desc', :include => :supplier)  
  end
  
  # Returns true if this is a current order (not finished and current time matches starts/ends).
  def current?
    !finished? && starts < Time.now && (!ends || ends > Time.now)
  end
  
  # Returns all finished or expired orders, exclude booked orders
  def self.find_finished
    find(:all, :conditions => ['(finished = ? OR ends < ?) AND booked = ?', true, Time.now, false], :order => 'ends desc', :include => :supplier)
  end
  
  # Return all booked Orders
  def self.find_booked
    find :all, :conditions => ['booked = ?', true], :order => 'ends desc', :include => :supplier
  end

  # search GroupOrder of given OrderGroup
  def group_order(ordergroup)
    unless finished
      return group_orders.detect {|o| o.order_group_id == ordergroup.id}
    else
      return group_order_results.detect {|o| o.group_name == ordergroup.name}
    end
  end
  
  # Returns OrderArticles in a nested Array, grouped by category and ordered by article name.
  # The array has the following form:
  # e.g: [["drugs",[teethpaste, toiletpaper]], ["fruits" => [apple, banana, lemon]]]
  def get_articles
    articles= order_articles.find :all, :include => :article, :order => "articles.name"
    articles_by_category= Hash.new
    ArticleCategory.find(:all).each do |category|
      articles_by_category.merge!(category.name.to_s => articles.select {|order_article| order_article.article.article_category == category})
    end
    # add articles without a category
    articles_by_category.merge!( "--" => articles.select {|order_article| order_article.article.article_category == nil})
    # return "clean" hash, sorted by category.name
    return articles_by_category.reject {|category, order_articles| order_articles.empty?}.sort

    # it could be so easy ... but that doesn't work for empty category-ids...
    # order_articles.group_by {|a| a.article.article_category}.sort {|a, b| a[0].name <=> b[0].name}
  end
  
  # Returns the defecit/benefit for the foodcoop
  def fcProfit(with_markup = true)
    groups_sum = with_markup ? sumPrice("groups") : sumPrice("groups_without_markup")
    groups_sum - invoice_amount + deposit - deposit_credit
  end
  
  # Returns the all round price of a finished order
  # "groups" returns the sum of all GroupOrderResults
  # "clear" returns the price without tax, deposit and markup
  # "gross" includes tax and deposit. this amount should be equal to suppliers bill
  # "fc", guess what...
  # for unfinished orders it returns the gross price
  def sumPrice(type = "gross")
    sum = 0
    if finished?
      if type == "groups"
        for groupResult in group_order_results
          for result in groupResult.group_order_article_results
            sum += result.order_article_result.gross_price * result.quantity
          end
        end
      elsif type == "groups_without_markup"
        for groupResult in group_order_results
          for result in groupResult.group_order_article_results
            oar = result.order_article_result
            sum += (oar.net_price + oar.deposit) * (1 + oar.tax/100) * result.quantity
          end
        end
      else
        for article in order_article_results
          case type
            when 'clear'
              sum += article.units_to_order * article.unit_quantity * article.net_price
            when 'gross'
              sum += article.units_to_order * article.unit_quantity * (article.net_price + article.deposit) * (article.tax / 100 + 1)
            when "fc"
              sum += article.units_to_order * article.unit_quantity * article.gross_price
          end
        end
      end
    else
      for article in order_articles
      	sum += article.units_to_order * article.article.gross_price * article.article.unit_quantity
      end	
    end
    sum
  end

  # Finishes this order. This will set the finish property to "true" and the end property to the current time.
  # Ignored if the order is already finished.
  # this will also copied the results into OrderArticleResult, GroupOrderArticleResult and GroupOrderResult
  def finish(user)
    unless finished?      
      transaction do
        #saves ordergroups, which take part in this order
        self.group_orders.each do |go|
          group_order_result = GroupOrderResult.create!(:order => self, 
                                                    :group_name => go.order_group.name,
                                                    :price => go.price)
        end
        # saves every article of the order
        self.get_articles.each do |category, articles| 
          articles.each do |oa|
            if oa.units_to_order >= 1 # save only successful ordered articles!
              article_result = OrderArticleResult.new(:order => self,
                                              :name => oa.article.name,
                                              :unit => oa.article.unit,
                                              :net_price => oa.article.net_price,
                                              :gross_price => oa.article.gross_price,
                                              :tax => oa.article.tax,
                                              :deposit => oa.article.deposit,
                                              :fc_markup => APP_CONFIG[:price_markup],
                                              :order_number => oa.article.order_number,
                                              :unit_quantity => oa.article.unit_quantity,
                                              :units_to_order => oa.units_to_order)
              article_result.save
              # saves the ordergroup results, belonging to the saved orderd article
              oa.group_order_articles.each do |goa|
                result = goa.orderResult
                # find appropriate GroupOrderResult
                group_order_result = GroupOrderResult.find(:first, :conditions => ['order_id = ? AND group_name = ?', self.id, goa.group_order.order_group.name])
                group_order_article_result = GroupOrderArticleResult.new(:order_article_result => article_result,
                                                         :group_order_result => group_order_result,
                                                         :quantity => result[:total],
                                                         :tolerance => result[:tolerance])
                group_order_article_result.save! if (group_order_article_result.quantity > 0)
              end
            end
          end
        end
        # set new order state (needed by notifyOrderFinished)
        self.finished = true
        self.ends = Time.now
        self.updated_by = user
        # delete data, which is no longer required, because everything is now in the result-tables
        self.group_orders.each do |go|
          go.destroy
        end
        self.order_articles.each do |oa|
          oa.destroy
        end
        self.save!
        # Update all GroupOrder.price
        self.updateAllGroupOrders
        # notify order groups
        notifyOrderFinished
      end      
    end
  end
  
  # Updates the ordered quantites of all OrderArticles from the GroupOrderArticles.
  def updateQuantities
    orderArticles = Hash.new  # holds the list of updated OrderArticles indexed by their id
    # Get all GroupOrderArticles for this order and update OrderArticle.quantity/.tolerance/.units_to_order from them...
    articles = GroupOrderArticle.find(:all, :conditions => ['group_order_id IN (?)', group_orders.collect { | o | o.id }], :include => [:order_article])
    for article in articles
      if (orderArticle = orderArticles[article.order_article.id.to_s]) 
        # OrderArticle has already been fetched, just update...
        orderArticle.quantity = orderArticle.quantity + article.quantity
        orderArticle.tolerance = orderArticle.tolerance + article.tolerance
        orderArticle.units_to_order = orderArticle.article.calculateOrderQuantity(orderArticle.quantity, orderArticle.tolerance)
      else
        # First update to OrderArticle, need to store in orderArticle hash...
        orderArticle = article.order_article
        orderArticle.quantity = article.quantity
        orderArticle.tolerance = article.tolerance
        orderArticle.units_to_order = orderArticle.article.calculateOrderQuantity(orderArticle.quantity, orderArticle.tolerance)
        orderArticles[orderArticle.id.to_s] = orderArticle
      end
    end
    # Commit changes to database...
    OrderArticle.transaction do
      orderArticles.each_value { | value | value.save! }
    end
  end
  
  # Updates the "price" attribute of GroupOrders or GroupOrderResults
  # This will be either the maximum value of a current order or the actual order value of a finished order.
  def updateAllGroupOrders
    unless finished?
      group_orders.each do |groupOrder|
        groupOrder.updatePrice
        groupOrder.save
      end
    else #for finished orders
      group_order_results.each do |groupOrderResult|
        groupOrderResult.updatePrice
      end  
    end
  end
  
  # Sets "booked"-attribute to true and updates all OrderGroup_account_balances
  def balance(user)
    raise "Bestellung wurde schon abgerechnet" if self.booked
    transaction_note = "Bestellung: #{name}, von #{starts.strftime('%d.%m.%Y')} bis #{ends.strftime('%d.%m.%Y')}"
    transaction do
      # update OrderGroups
      group_order_results.each do |result|
        price = result.price * -1 # decrease! account balance
        OrderGroup.find_by_name(result.group_name).addFinancialTransaction(price, transaction_note, user)        
      end
      self.booked = true
      self.updated_by = user
      self.save!
    end
  end
  
  # returns the corresponding message for the status
  def status
    if !self.finished? && self.ends > Time.now
      _("running")
    elsif !self.finished? && self.ends < Time.now
      _("expired")
    elsif self.finished? && !self.booked?
      _("finished")
    else
      _("balanced")
    end
  end
  
  protected

    def validate
       errors.add(:ends, "muss nach dem Bestellstart liegen (oder leer bleiben)") if (ends && starts && ends <= starts)
    end
    
    def include_articles
      errors.add(:order_articles, _("There must be at least one article selected")) if order_articles.empty?
    end

  private
  
    # Sends "order finished" messages to users who have participated in this order.
    def notifyOrderFinished 
      # Loop through GroupOrderResults for this order: 
      for group_order in self.group_order_results        
        order_group = OrderGroup.find_by_name(group_order.group_name)
        # Determine group users that want a notification message:
        users = order_group.users.reject{|u| u.settings["notify.orderFinished"] != '1'}
        unless (users.empty?)
          # Assemble the order message text:
          results = group_order.group_order_article_results.find(:all, :include => [:order_article_result])
          # Create user notification messages:
          recipients = users.collect{|u| u.nick}.join(', ')
          for user in users
            Message.from_template(
              'order_finished', 
              {:user => user, :group => order_group, :order => self, :results => results, :total => group_order.price}, 
              {:recipient_id => user.id, :recipients => recipients, :subject => "Bestellung beendet: #{self.name}"}
            ).save!
          end
        end
      end
    end
  
end
