# encoding: utf-8
#
class Order < ApplicationRecord
  attr_accessor :ignore_warnings

  # Associations
  has_many :order_articles, :dependent => :destroy
  has_many :articles, :through => :order_articles
  has_many :group_orders, :dependent => :destroy
  has_many :ordergroups, :through => :group_orders
  has_many :users_ordered, :through => :ordergroups, :source => :users
  has_many :comments, -> { order('created_at') }, :class_name => "OrderComment"
  has_many :stock_changes
  belongs_to :invoice
  belongs_to :supplier
  belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_user_id'
  belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_user_id'

  enum end_action: { no_end_action: 0, auto_close: 1, auto_close_and_send: 2, auto_close_and_send_min_quantity: 3 }

  # Validations
  validates_presence_of :starts
  validate :starts_before_ends, :include_articles
  validate :keep_ordered_articles

  # Callbacks
  after_save :save_order_articles, :update_price_of_group_orders

  # Finders
  scope :open, -> { where(state: 'open').order('ends DESC') }
  scope :finished, -> { where("orders.state = 'finished' OR orders.state = 'closed'").order('ends DESC') }
  scope :finished_not_closed, -> { where(state: 'finished').order('ends DESC') }
  scope :closed, -> { where(state: 'closed').order('ends DESC') }
  scope :stockit, -> { where(supplier_id: 0).order('ends DESC') }
  scope :recent, -> { order('starts DESC').limit(10) }
  scope :stock_group_order, -> { group_orders.where(ordergroup_id: nil).first }
  scope :with_invoice, -> { where.not(invoice: nil) }

  # Allow separate inputs for date and time
  #   with workaround for https://github.com/einzige/date_time_attribute/issues/14
  include DateTimeAttributeValidate
  date_time_attribute :starts, :boxfill, :ends

  def stockit?
    supplier_id == 0
  end

  def name
    stockit? ? I18n.t('orders.model.stock') : supplier.name
  end

  def articles_for_ordering
    if stockit?
      # make sure to include those articles which are no longer available
      # but which have already been ordered in this stock order
      StockArticle.available.includes(:article_category).
        order('article_categories.name', 'articles.name').reject{ |a|
        a.quantity_available <= 0 && !a.ordered_in_order?(self)
      }.group_by { |a| a.article_category.name }
    else
      supplier.articles.available.group_by { |a| a.article_category.name }
    end
  end

  def supplier_articles
    if stockit?
      StockArticle.undeleted.reorder('articles.name')
    else
      supplier.articles.undeleted.reorder('articles.name')
    end
  end

  # Save ids, and create/delete order_articles after successfully saved the order
  def article_ids=(ids)
    @article_ids = ids
  end

  def article_ids
    @article_ids ||= order_articles.map { |a| a.article_id.to_s }
  end

  # Returns an array of article ids that lead to a validation error.
  def erroneous_article_ids
    @erroneous_article_ids ||= []
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

  def boxfill?
    FoodsoftConfig[:use_boxfill] && open? && boxfill.present? && boxfill < Time.now
  end

  def is_boxfill_useful?
    FoodsoftConfig[:use_boxfill] && supplier.try(:has_tolerance?)
  end

  def expired?
    ends.present? && ends < Time.now
  end

  # sets up first guess of dates when initializing a new object
  # I guess `def initialize` would work, but it's tricky http://stackoverflow.com/questions/1186400
  def init_dates
    self.starts ||= Time.now
    if FoodsoftConfig[:order_schedule]
      # try to be smart when picking a reference day
      last = (DateTime.parse(FoodsoftConfig[:order_schedule][:initial]) rescue nil)
      last ||= Order.finished.reorder(:starts).first.try(:starts)
      last ||= self.starts
      # adjust boxfill and end date
      self.boxfill ||= FoodsoftDateUtil.next_occurrence last, self.starts, FoodsoftConfig[:order_schedule][:boxfill] if is_boxfill_useful?
      self.ends ||= FoodsoftDateUtil.next_occurrence last, self.starts, FoodsoftConfig[:order_schedule][:ends]
    end
    self
  end

  # search GroupOrder of given Ordergroup
  def group_order(ordergroup)
    group_orders.where(:ordergroup_id => ordergroup.id).first
  end

  def stock_group_order
    group_orders.where(:ordergroup_id => nil).first
  end

  # Returns OrderArticles in a nested Array, grouped by category and ordered by article name.
  # The array has the following form:
  # e.g: [["drugs",[teethpaste, toiletpaper]], ["fruits" => [apple, banana, lemon]]]
  def articles_grouped_by_category
    @articles_grouped_by_category ||= order_articles.
        includes([:article_price, :group_order_articles, :article => :article_category]).
        order('articles.name').
        group_by { |a| a.article.article_category.name }.
        sort { |a, b| a[0] <=> b[0] }
  end

  def articles_sort_by_category
    order_articles.includes(:article).order('articles.name').sort do |a,b|
      a.article.article_category.name <=> b.article.article_category.name
    end
  end

  # Returns the defecit/benefit for the foodcoop
  # Requires a valid invoice, belonging to this order
  #FIXME: Consider order.foodcoop_result
  def profit(options = {})
    markup = options[:without_markup] || false
    if invoice
      groups_sum = markup ? sum(:groups_without_markup) : sum(:groups)
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
      for oa in order_articles.ordered.includes(:article, :article_price)
        quantity = oa.units * oa.price.unit_quantity
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
      for go in group_orders.includes(group_order_articles: {order_article: [:article, :article_price]})
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
        # set new order state (needed by notify_order_finished)
        update_attributes!(:state => 'finished', :ends => Time.now, :updated_by => user)

        # Update order_articles. Save the current article_price to keep price consistency
        # Also save results for each group_order_result
        # Clean up
        order_articles.includes(:article).each do |oa|
          oa.update_attribute(:article_price, oa.article.article_prices.first)
          oa.group_order_articles.each do |goa|
            goa.save_results!
            # Delete no longer required order-history (group_order_article_quantities) and
            # TODO: Do we need articles, which aren't ordered? (units_to_order == 0 ?)
            #    A: Yes, we do - for redistributing articles when the number of articles
            #       delivered changes, and for statistics on popular articles. Records
            #       with both tolerance and quantity zero can be deleted.
            #goa.group_order_article_quantities.clear
          end
        end

        # Update GroupOrder prices
        group_orders.each(&:update_price!)

        # Stats
        ordergroups.each(&:update_stats!)

        # Notifications
        Resque.enqueue(UserNotifier, FoodsoftConfig.scope, 'finished_order', self.id)
      end
    end
  end

  # Sets order.status to 'close' and updates all Ordergroup.account_balances
  def close!(user, transaction_type = nil)
    raise I18n.t('orders.model.error_closed') if closed?
    transaction_note = I18n.t('orders.model.notice_close', :name => name,
                              :ends => ends.strftime(I18n.t('date.formats.default')))

    gos = group_orders.includes(:ordergroup)              # Fetch group_orders
    gos.each { |group_order| group_order.update_price! }  # Update prices of group_orders

    transaction do                                        # Start updating account balances
      for group_order in gos
        if group_order.ordergroup
          price = group_order.price * -1                  # decrease! account balance
          group_order.ordergroup.add_financial_transaction!(price, transaction_note, user, transaction_type)
        end
      end

      if stockit?                                         # Decreases the quantity of stock_articles
        for oa in order_articles.includes(:article)
          oa.update_results!                              # Update units_to_order of order_article
          stock_changes.create! :stock_article => oa.article, :quantity => oa.units_to_order*-1
        end
      end

      self.update_attributes! :state => 'closed', :updated_by => user, :foodcoop_result => profit
    end
  end

  # Close the order directly, without automaticly updating ordergroups account balances
  def close_direct!(user)
    raise I18n.t('orders.model.error_closed') if closed?
    comments.create(user: user, text: I18n.t('orders.model.close_direct_message')) unless FoodsoftConfig[:charge_members_manually]
    update_attributes! state: 'closed', updated_by: user
  end

  def send_to_supplier!(user)
    Mailer.deliver_now_with_default_locale do
      Mailer.order_result_supplier(user, self)
    end
    update!(last_sent_mail: Time.now)
  end

  def do_end_action!
    if auto_close?
      finish!(created_by)
    elsif auto_close_and_send?
      finish!(created_by)
      send_to_supplier!(created_by)
    elsif auto_close_and_send_min_quantity?
      finish!(created_by)
      send_to_supplier!(created_by) if sum >= supplier.min_order_quantity.to_r
    end
  end

  def self.finish_ended!
    orders = Order.where.not(end_action: Order.end_actions[:no_end_action]).where(state: 'open').where('ends <= ?', DateTime.now)
    orders.each do |order|
      begin
        order.do_end_action!
      rescue => error
        ExceptionNotifier.notify_exception(error, data: {foodcoop: FoodsoftConfig.scope, order_id: order.id})
      end
    end
  end

  protected

  def starts_before_ends
    delta = Rails.env.test? ? 1 : 0 # since Rails 4.2 tests appear to have time differences, with this validation failing
    errors.add(:ends, I18n.t('orders.model.error_starts_before_ends')) if ends && starts && ends <= (starts-delta)
    errors.add(:ends, I18n.t('orders.model.error_boxfill_before_ends')) if ends && boxfill && ends <= (boxfill-delta)
    errors.add(:boxfill, I18n.t('orders.model.error_starts_before_boxfill')) if boxfill && starts && boxfill <= (starts-delta)
  end

  def include_articles
    errors.add(:articles, I18n.t('orders.model.error_nosel')) if article_ids.empty?
  end

  def keep_ordered_articles
    chosen_order_articles = order_articles.where(article_id: article_ids)
    to_be_removed = order_articles - chosen_order_articles
    to_be_removed_but_ordered = to_be_removed.select { |a| a.quantity > 0 || a.tolerance > 0 }
    unless to_be_removed_but_ordered.empty? || ignore_warnings
      errors.add(:articles, I18n.t(stockit? ? 'orders.model.warning_ordered_stock' : 'orders.model.warning_ordered'))
      @erroneous_article_ids = to_be_removed_but_ordered.map { |a| a.article_id }
    end
  end

  def save_order_articles
    # fetch selected articles
    articles_list = Article.find(article_ids)
    # create new order_articles
    (articles_list - articles).each { |article| order_articles.create(:article => article) }
    # delete old order_articles
    articles.reject { |article| articles_list.include?(article) }.each do |article|
      order_articles.detect { |order_article| order_article.article_id == article.id }.destroy
    end
  end

  private

  # Updates the "price" attribute of GroupOrders or GroupOrderResults
  # This will be either the maximum value of a current order or the actual order value of a finished order.
  def update_price_of_group_orders
    group_orders.each { |group_order| group_order.update_price! }
  end

end
