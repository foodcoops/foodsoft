# == Schema Information
# Schema version: 20090102171850
#
# Table name: groups
#
#  id                  :integer(4)      not null, primary key
#  type                :string(255)     default(""), not null
#  name                :string(255)     default(""), not null
#  description         :string(255)
#  actual_size         :integer(4)
#  account_balance     :decimal(8, 2)   default(0.0), not null
#  account_updated     :datetime
#  created_on          :datetime        not null
#  role_admin          :boolean(1)      not null
#  role_suppliers      :boolean(1)      not null
#  role_article_meta   :boolean(1)      not null
#  role_finance        :boolean(1)      not null
#  role_orders         :boolean(1)      not null
#  weekly_task         :boolean(1)
#  weekday             :integer(4)
#  task_name           :string(255)
#  task_description    :string(255)
#  task_required_users :integer(4)      default(1)
#

# OrderGroups can order, they are "children" of the class Group
# 
# OrderGroup have the following attributes, in addition to Group
# * account_balance (decimal)
# * account_updated (datetime)
# * actual_size (int) : how many persons are ordering through the OrderGroup
class OrderGroup < Group
  has_many :financial_transactions, :dependent => :destroy
  has_many :group_orders, :dependent => :destroy
  has_many :orders, :through => :group_orders
  has_many :group_order_article_results, :through => :group_orders # TODO: whats this???
  has_many :group_order_results, :finder_sql => 'SELECT * FROM group_order_results as r WHERE r.group_name = "#{name}"'

  validates_inclusion_of :actual_size, :in => 1..99 
  validates_numericality_of :account_balance, :message => 'ist keine gültige Zahl'
  
  attr_accessible :actual_size, :account_updated
  
  # messages
  ERR_NAME_IS_USED_IN_ARCHIVE = "Der Name ist von einer ehemaligen Gruppe verwendet worden."
    
  # if the order_group.name is changed, group_order_result.name has to be adapted
  def before_update
    ordergroup = OrderGroup.find(self.id)
    unless (ordergroup.name == self.name) || ordergroup.group_order_results.empty?
      # rename all finished orders
      for result in ordergroup.group_order_results
        result.update_attribute(:group_name, self.name)
      end
    end
  end
    
  # Returns the available funds for this order group (the account_balance minus price of all non-booked GroupOrders of this group).
  # * excludeGroupOrder (GroupOrder): exclude this GroupOrder from the calculation
  def getAvailableFunds(excludeGroupOrder = nil)
    funds = account_balance
    for order in GroupOrder.find_all_by_order_group_id(self.id)
      unless order == excludeGroupOrder
        funds -= order.price
      end
    end
    for order_result in self.findFinishedNotBooked
      funds -= order_result.price
    end
    return funds
  end
  
  # Creates a new FinancialTransaction for this OrderGroup and updates the account_balance accordingly.
  # Throws an exception if it fails.
  def addFinancialTransaction(amount, note, user)
    transaction do      
      trans = FinancialTransaction.new(:order_group => self, :amount => amount, :note => note, :user => user)
      trans.save!
      self.account_balance += trans.amount
      self.account_updated = trans.created_on
      save!
      notifyNegativeBalance(trans) 
    end
  end
  
  # Returns all GroupOrders by this group that are currently running.
  def findCurrent
    group_orders.find(:all, :conditions => ["orders.finished = ? AND orders.starts < ? AND (orders.ends IS NULL OR orders.ends > ?)", false, Time.now, Time.now], :include => :order)
  end
  
  #find expired (lapsed) but not manually finished orders
  def findExpiredOrders
    group_orders.find(:all, :conditions => ["orders.ends < ?", Time.now], :include => :order, :order => 'orders.ends DESC')
  end
  
  # Returns all GroupOrderResults by this group that are finished but not booked yet.
  def findFinishedNotBooked 
    GroupOrderResult.find(:all, 
                          :conditions => ["group_order_results.group_name = ? AND group_order_results.order_id = orders.id AND orders.finished = ? AND orders.booked = ? ", self.name, true, false],
                          :include => :order,
                          :order => 'orders.ends DESC')
  end
  
  # Returns all GroupOrderResults for booked orders
  def findBookedOrders(limit = false, offset = 0)
    GroupOrderResult.find(:all,
                         :conditions => ["group_order_results.group_name = ? AND group_order_results.order_id = orders.id AND orders.finished = ? AND orders.booked = ? ", self.name, true, true],
                         :include => :order,
                         :order => "orders.ends DESC",
                         :limit => limit, 
                         :offset => offset)
  end
  
 private
  
  # If this order group's account balance is made negative by the given/last transaction, 
  # a message is sent to all users who have enabled notification.
  def notifyNegativeBalance(transaction)
    # Notify only when order group had a positive balance before the last transaction:
    if (transaction.amount < 0 && self.account_balance < 0 && self.account_balance - transaction.amount >= 0) 
      users = self.users.reject{|u| u.settings["notify.negativeBalance"] != '1'}
      unless (users.empty?)
        recipients = users.collect{|u| u.nick}.join(', ')
        for user in users
          Message.from_template(
            'negative_balance', 
            {:user => user, :group => self, :transaction => transaction}, 
            {:recipient_id => user.id, :recipients => recipients, :subject => "Gruppenkonto im Minus"}
          ).save!
        end        
      end
    end    
  end
  
  # before create or update, check if the name is already used in GroupOrderResults
  def validate_on_create
    errors.add(:name, ERR_NAME_IS_USED_IN_ARCHIVE) unless GroupOrderResult.find_all_by_group_name(self.name).empty?
  end
  def validate_on_update
    ordergroup = OrderGroup.find(self.id)
    errors.add(:name, ERR_NAME_IS_USED_IN_ARCHIVE) unless ordergroup.name == self.name || GroupOrderResult.find_all_by_group_name(self.name).empty?
  end

end
