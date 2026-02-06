#
# Ordergroups can order, they are "children" of the class Group
#
# Ordergroup have the following attributes, in addition to Group
# * account_balance (decimal)
class Ordergroup < Group
  include CustomFields

  APPLE_MONTH_AGO = 6 # How many month back we will count tasks and orders sum

  serialize :stats

  has_many :financial_transactions
  has_many :group_orders
  has_many :orders, through: :group_orders
  has_many :group_order_articles, through: :group_orders

  validates :account_balance, numericality: { message: I18n.t('ordergroups.model.invalid_balance') }
  validate :uniqueness_of_name, :uniqueness_of_members

  after_create :update_stats!

  scope :active, -> { joins(:orders).where(orders: { starts: (Time.now.months_ago(3)..Time.now) }).group(:id) }

  def contact
    "#{contact_phone} (#{contact_person})"
  end

  def non_members
    User.natural_order.all.reject { |u| users.include?(u) || u.ordergroup }
  end

  def self.include_transaction_class_sum
    columns = column_names.map { |col| "groups.#{col}" }
    FinancialTransactionClass.all.find_each do |c|
      columns << "sum(CASE financial_transaction_types.financial_transaction_class_id WHEN #{c.id} THEN financial_transactions.amount ELSE 0 END) AS sum_of_class_#{c.id}"
    end

    select(columns.join(', '))
      .joins('LEFT JOIN financial_transactions ON groups.id = financial_transactions.ordergroup_id')
      .joins('LEFT JOIN financial_transaction_types ON financial_transaction_types.id = financial_transactions.financial_transaction_type_id')
      .group('groups.id')
  end

  def self.custom_fields
    fields = FoodsoftConfig[:custom_fields] && FoodsoftConfig[:custom_fields][:ordergroup]
    return [] unless fields

    fields.map(&:deep_symbolize_keys)
  end

  def last_user_activity
    last_active_user = users.order('users.last_activity DESC').first
    return unless last_active_user

    last_active_user.last_activity
  end

  # the most recent order this ordergroup was participating in
  def last_order
    orders.order('orders.starts DESC').first
  end

  def value_of_open_orders(exclude = nil)
    group_orders.in_open_orders.reject { |go| go == exclude }.collect(&:price).sum
  end

  def value_of_finished_orders(exclude = nil)
    group_orders.in_finished_orders.reject { |go| go == exclude }.collect(&:price).sum
  end

  # Returns the available funds for this order group (the account_balance minus price of all non-closed GroupOrders of this group).
  # * exclude (GroupOrder): exclude this GroupOrder from the calculation
  def get_available_funds(exclude = nil)
    account_balance - value_of_open_orders(exclude) - value_of_finished_orders(exclude)
  end

  def financial_transaction_class_balance(klass)
    financial_transactions
      .joins(:financial_transaction_type)
      .where(financial_transaction_types: { financial_transaction_class_id: klass })
      .sum(:amount)
  end

  # Creates a new FinancialTransaction for this Ordergroup and updates the account_balance accordingly.
  # Throws an exception if it fails.
  def add_financial_transaction!(amount, note, user, transaction_type, link = nil, group_order = nil)
    transaction do
      t = FinancialTransaction.new(ordergroup: self, amount: amount, note: note, user: user,
                                   financial_transaction_type: transaction_type, financial_link: link, group_order: group_order)
      t.save!
      update_balance!
      # Notify only when order group had a positive balance before the last transaction:
      NotifyNegativeBalanceJob.perform_later(self, t) if t.amount < 0 && account_balance < 0 && account_balance - t.amount >= 0
      t
    end
  end

  # Recomputes job statistics from group orders.
  def update_stats!
    # Get hours for every job of each user in period
    jobs = users.to_a.sum { |u| u.tasks.done.where('updated_on > ?', APPLE_MONTH_AGO.month.ago).sum(:duration) }
    # Get group_order.price for every finished order in this period
    orders_sum = group_orders.includes(:order).merge(Order.finished).where('orders.ends >= ?',
                                                                           APPLE_MONTH_AGO.month.ago).references(:orders).sum(:price)

    @readonly = false # Dirty hack, avoid getting RecordReadOnly exception when called in task after_save callback. A rails bug?
    update_attribute(:stats, { jobs_size: jobs, orders_sum: orders_sum })
  end

  def update_balance!
    new_account_balance = financial_transactions
                          .joins(financial_transaction_type: [:financial_transaction_class])
                          .where({ financial_transaction_classes: { ignore_for_account_balance: false } })
                          .sum(:amount)
    update_attribute :account_balance, new_account_balance
  end

  def avg_jobs_per_euro
    stats[:jobs_size].to_f / stats[:orders_sum].to_f
  rescue StandardError
    0
  end

  # This is the ordergroup job per euro performance
  # in comparison to the hole foodcoop average
  def apples
    ((avg_jobs_per_euro / Ordergroup.avg_jobs_per_euro) * 100).to_i
  rescue StandardError
    0
  end

  # If the the option stop_ordering_under is set, the ordergroup is only allowed to participate in an order,
  # when the apples value is above the configured amount.
  # The restriction can be deactivated for each ordergroup.
  # Only ordergroups, which have participated in more than 5 orders in total and more than 2 orders in apple time period
  def not_enough_apples?
    FoodsoftConfig[:use_apple_points] &&
      FoodsoftConfig[:stop_ordering_under].present? &&
      !ignore_apple_restriction &&
      apples < FoodsoftConfig[:stop_ordering_under] &&
      group_orders.count > 5 &&
      group_orders.joins(:order).merge(Order.finished).where('orders.ends >= ?', APPLE_MONTH_AGO.month.ago).count > 2
  end

  # Global average
  def self.avg_jobs_per_euro
    stats = Ordergroup.pluck(:stats)
    begin
      stats.sum { |s| s[:jobs_size].to_f } / stats.sum { |s| s[:orders_sum].to_f }
    rescue StandardError
      0
    end
  end

  def account_updated
    financial_transactions.last.try(:updated_on) || created_on
  end

  def self.sort_by_param(param)
    param ||= 'name'

    sort_param_map = {
      'name' => 'name',
      'name_reverse' => 'name DESC',
      'members_count' => 'count(users.id)',
      'members_count_reverse' => 'count(users.id) DESC',
      'last_user_activity' => 'max(users.last_activity)',
      'last_user_activity_reverse' => 'max(users.last_activity) DESC',
      'last_order' => 'max(orders.starts)',
      'last_order_reverse' => 'max(orders.starts) DESC'
    }

    result = self
    result = result.left_joins(:users).group('groups.id') if param.starts_with?('members_count', 'last_user_activity')
    result = result.left_joins(:orders).group('groups.id') if param.starts_with?('last_order')

    # Never pass user input data to Arel.sql() because of SQL Injection vulnerabilities.
    # This case here is okay, as param is mapped to the actual order string.
    result.order(Arel.sql(sort_param_map[param]))
  end

  private

  # Make sure, that a user can only be in one ordergroup
  def uniqueness_of_members
    users.each do |user|
      next unless user.groups.where(type: 'Ordergroup').size > 1

      errors.add :user_tokens,
                 I18n.t('ordergroups.model.error_single_group',
                        user: user.display)
    end
  end

  # Make sure, the name is uniq, add usefull message if uniq group is already deleted
  def uniqueness_of_name
    group = Ordergroup.where(name: name)
    group = group.where.not(id: id) unless new_record?
    return unless group.exists?

    message = group.first.deleted? ? :taken_with_deleted : :taken
    errors.add :name, message
  end
end
