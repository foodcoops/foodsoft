# Ordergroups can order, they are "children" of the class Group
# 
# Ordergroup have the following attributes, in addition to Group
# * account_balance (decimal)
# * account_updated (datetime)
class Ordergroup < Group
  acts_as_paranoid                    # Avoid deleting the ordergroup for consistency of order-results
  extend ActiveSupport::Memoizable    # Ability to cache method results. Use memoize :expensive_method
  serialize :stats

  has_many :financial_transactions, :order => "created_on DESC"
  has_many :group_orders
  has_many :orders, :through => :group_orders

  validates_numericality_of :account_balance, :message => 'ist keine gültige Zahl'

  after_create :update_stats!

  def contact
    "#{contact_phone} (#{contact_person})"
  end
  def non_members
    User.all(:order => 'nick').reject { |u| (users.include?(u) || u.ordergroup) }
  end

  def value_of_open_orders(exclude = nil)
    group_orders.open.reject{|go| go == exclude}.collect(&:price).sum
  end
  
  def value_of_finished_orders(exclude = nil)
    group_orders.finished.reject{|go| go == exclude}.collect(&:price).sum
  end

  # Returns the available funds for this order group (the account_balance minus price of all non-closed GroupOrders of this group).
  # * exclude (GroupOrder): exclude this GroupOrder from the calculation
  def get_available_funds(exclude = nil)
    account_balance - value_of_open_orders(exclude) - value_of_finished_orders(exclude)
  end
  memoize :get_available_funds

  # Creates a new FinancialTransaction for this Ordergroup and updates the account_balance accordingly.
  # Throws an exception if it fails.
  def add_financial_transaction(amount, note, user)
    transaction do      
      trans = FinancialTransaction.new(:ordergroup => self, :amount => amount, :note => note, :user => user)
      trans.save!
      self.account_balance += trans.amount
      self.account_updated = trans.created_on
      save!
      notify_negative_balance(trans) 
    end
  end

  def update_stats!
    time = 6.month.ago
    jobs = users.collect { |u| u.tasks.done.sum('duration', :conditions => ["updated_on > ?", time]) }.sum
    orders_sum = group_orders.select { |go| !go.order.ends.nil? && go.order.ends > time }.collect(&:price).sum
    update_attribute(:stats, {:jobs_size => jobs, :orders_sum => orders_sum})
  end

  def avg_jobs_per_euro
    stats[:orders_sum] != 0 ? stats[:jobs_size].to_f / stats[:orders_sum].to_f : 0
  end

  # Global average
  def self.avg_jobs_per_euro
    stats = Ordergroup.all.collect(&:stats)
    stats.collect {|s| s[:jobs_size].to_f }.sum / stats.collect {|s| s[:orders_sum].to_f }.sum
  end
  
  private
  
  # If this order group's account balance is made negative by the given/last transaction, 
  # a message is sent to all users who have enabled notification.
  def notify_negative_balance(transaction)
    # Notify only when order group had a positive balance before the last transaction:
    if (transaction.amount < 0 && self.account_balance < 0 && self.account_balance - transaction.amount >= 0)
      for user in users
        Mailer.negative_balance(user,transaction).deliver if user.settings["notify.negativeBalance"] == '1'
      end
    end
  end
  
end

# == Schema Information
#
# Table name: groups
#
#  id                  :integer(4)      not null, primary key
#  type                :string(255)     default(""), not null
#  name                :string(255)     default(""), not null
#  description         :string(255)
#  account_balance     :decimal(8, 2)   default(0.0), not null
#  account_updated     :datetime
#  created_on          :datetime        not null
#  role_admin          :boolean(1)      default(FALSE), not null
#  role_suppliers      :boolean(1)      default(FALSE), not null
#  role_article_meta   :boolean(1)      default(FALSE), not null
#  role_finance        :boolean(1)      default(FALSE), not null
#  role_orders         :boolean(1)      default(FALSE), not null
#  weekly_task         :boolean(1)      default(FALSE)
#  weekday             :integer(4)
#  task_name           :string(255)
#  task_description    :string(255)
#  task_required_users :integer(4)      default(1)
#  deleted_at          :datetime
#  contact_person      :string(255)
#  contact_phone       :string(255)
#  contact_address     :string(255)
#  stats               :text
#  task_duration       :integer(4)      default(1)
#

