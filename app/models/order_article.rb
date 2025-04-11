# An OrderArticle represents a single Article that is part of an Order.
class OrderArticle < ApplicationRecord
  include FindEachWithOrder

  attr_reader :update_global_price

  belongs_to :order
  belongs_to :article
  belongs_to :article_price, optional: true
  has_many :group_order_articles, dependent: :destroy

  validates :order_id, :article_id, presence: true
  validate :article_and_price_exist
  validates :article_id, uniqueness: { scope: :order_id }

  _ordered_sql = 'order_articles.units_to_order > 0 OR order_articles.units_billed > 0 OR order_articles.units_received > 0'
  scope :ordered, -> { where(_ordered_sql) }
  scope :ordered_or_member, lambda {
                              includes(:group_order_articles).where("#{_ordered_sql} OR order_articles.quantity > 0 OR group_order_articles.result > 0")
                            }

  before_create :init_from_balancing
  after_destroy :update_ordergroup_prices

  def self.ransackable_attributes(_auth_object = nil)
    %w[id order_id article_id quantity tolerance units_to_order]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[order article]
  end

  # This method returns either the ArticlePrice or the Article
  # The first will be set, when the the order is finished
  def price
    article_price || article
  end

  # latest information on available units
  def units
    return units_received unless units_received.nil?
    return units_billed unless units_billed.nil?

    units_to_order
  end

  # Count quantities of belonging group_orders.
  # In balancing this can differ from ordered (by supplier) quantity for this article.
  def group_orders_sum
    quantity = group_order_articles.collect(&:result).sum
    { quantity: quantity, price: quantity * price.fc_price }
  end

  # Update quantity/tolerance/units_to_order from group_order_articles
  def update_results!
    if order.open?
      self.quantity = group_order_articles.collect(&:quantity).sum
      self.tolerance = group_order_articles.collect(&:tolerance).sum
      self.units_to_order = calculate_units_to_order(quantity, tolerance)
      enforce_boxfill if order.boxfill?
      save!
    elsif order.finished?
      update_attribute(:units_to_order, group_order_articles.collect(&:result).sum)
    end
  end

  # Returns how many units of the belonging article need to be ordered given the specified order quantity and tolerance.
  # This is determined by calculating how many units can be ordered from the given order quantity, using
  # the tolerance to order an additional unit if the order quantity is not quiet sufficient.
  # There must always be at least one item in a unit that is an ordered quantity (no units are ever entirely
  # filled by tolerance items only).
  #
  # Example:
  #
  # unit_quantity | quantity | tolerance | calculate_units_to_order
  # --------------+----------+-----------+-----------------------
  #      4        |    0     |     2     |           0
  #      4        |    0     |     5     |           0
  #      4        |    2     |     2     |           1
  #      4        |    4     |     2     |           1
  #      4        |    4     |     4     |           1
  #      4        |    5     |     3     |           2
  #      4        |    5     |     4     |           2
  #
  def calculate_units_to_order(quantity, tolerance = 0)
    unit_size = price.unit_quantity
    units = quantity / unit_size
    remainder = quantity % unit_size
    units += ((remainder > 0) && (remainder + tolerance >= unit_size) ? 1 : 0)
  end

  # Calculate price for ordered quantity.
  def total_price
    units * price.unit_quantity * price.price
  end

  # Calculate gross price for ordered qunatity.
  def total_gross_price
    units * price.unit_quantity * price.gross_price
  end

  def ordered_quantities_different_from_group_orders?(ordered_mark = '!', billed_mark = '?', received_mark = '?')
    if !units_received.nil?
      (units_received * price.unit_quantity) == group_orders_sum[:quantity] ? false : received_mark
    elsif !units_billed.nil?
      (units_billed * price.unit_quantity) == group_orders_sum[:quantity] ? false : billed_mark
    elsif !units_to_order.nil?
      (units_to_order * price.unit_quantity) == group_orders_sum[:quantity] ? false : ordered_mark
    end
  end

  # redistribute articles over ordergroups
  #   quantity       Number of units to distribute
  #   surplus        What to do when there are more articles than ordered quantity
  #                    :tolerance   fill member orders' tolerance
  #                    :stock       move to stock
  #                    nil          nothing; for catching the remaining count
  #   update_totals  Whether to update group_order and ordergroup totals
  # returns array with counts for each surplus method
  def redistribute(quantity, surplus = [:tolerance], update_totals = true)
    qty_left = quantity
    counts = [0] * surplus.length

    if surplus.index(:tolerance).nil?
      qty_for_members = [qty_left, self.quantity].min
    else
      qty_for_members = [qty_left, self.quantity + tolerance].min
      counts[surplus.index(:tolerance)] = [0, qty_for_members - self.quantity].max
    end

    # Recompute
    group_order_articles.each { |goa| goa.save_results! qty_for_members }
    qty_left -= qty_for_members

    # if there's anything left, move to stock if wanted
    if qty_left > 0 && surplus.index(:stock)
      counts[surplus.index(:stock)] = qty_left
      # 1) find existing stock article with same name, unit, price
      # 2) if not found, create new stock article
      #      avoiding duplicate stock article names
    end
    counts[surplus.index(nil)] = qty_left if qty_left > 0 && surplus.index(nil)

    # Update GroupOrder prices & Ordergroup stats
    # TODO only affected group_orders, and once after redistributing all articles
    if update_totals
      update_ordergroup_prices
      order.ordergroups.each(&:update_stats!)
    end

    # TODO: notifications

    counts
  end

  # Updates order_article and belongings during balancing process
  def update_article_and_price!(order_article_attributes, article_attributes, price_attributes = nil)
    OrderArticle.transaction do
      # Updates self
      update!(order_article_attributes)

      # Updates article
      article.update!(article_attributes)

      # Updates article_price belonging to current order article
      if price_attributes.present?
        article_price.attributes = price_attributes
        if article_price.changed?
          # Updates also price attributes of article if update_global_price is selected
          if update_global_price
            article.update!(price_attributes)
            self.article_price = article.article_prices.first and save # Assign new created article price to order article
          else
            # Creates a new article_price if neccessary
            # Ugly workaround for faulty db structure:
            # Set created_at timestamp to just before the latest article price, to make sure the current article price isn't changed
            create_article_price!(price_attributes.merge(article_id: article_id, created_at: article.article_prices.last.created_at - 1.second)) and save
          end

          # Updates ordergroup values
          update_ordergroup_prices
        end
      end
    end
  end

  def update_global_price=(value)
    @update_global_price = [true, '1'].include?(value) ? true : false
  end

  # @return [Number] Units missing for the last +unit_quantity+ of the article.
  def missing_units
    _missing_units(price.unit_quantity, quantity, tolerance)
  end

  def missing_units_was
    _missing_units(price.unit_quantity, quantity_was, tolerance_was)
  end

  # Check if the result of any associated GroupOrderArticle was overridden manually
  def result_manually_changed?
    group_order_articles.any? { |goa| goa.result_manually_changed? }
  end

  def difference_received_ordered
    (units_received || 0) - units_to_order
  end

  private

  def article_and_price_exist
    if !(article = Article.find(article_id)) || article.fc_price.nil?
      errors.add(:article,
                 I18n.t('model.order_article.error_price'))
    end
  rescue StandardError
    errors.add(:article, I18n.t('model.order_article.error_price'))
  end

  # Associate with current article price if created in a finished order
  def init_from_balancing
    return unless order.present? && order.finished?

    self.article_price = article.article_prices.first
  end

  def update_ordergroup_prices
    # updates prices of ALL ordergroups - these are actually too many
    # in case of performance issues, update only ordergroups, which ordered this article
    # CAUTION: in after_destroy callback related records (e.g. group_order_articles) are already non-existent
    order.group_orders.each(&:update_price!)
  end

  # Throws an exception when the changed article decreases the amount of filled boxes.
  def enforce_boxfill
    # Either nothing changes, or the tolerance increases,
    # missing_units decreases and the amount doesn't decrease, or
    # tolerance was moved to quantity. Only then are changes allowed in the boxfill phase.
    delta_q = quantity - quantity_was
    delta_t = tolerance - tolerance_was
    delta_mis = missing_units - missing_units_was
    delta_box = units_to_order - units_to_order_was
    unless (delta_q == 0 && delta_t >= 0) ||
           (delta_mis < 0 && delta_box >= 0 && delta_t >= 0) ||
           (delta_q > 0 && delta_q == -delta_t)
      raise ActiveRecord::RecordNotSaved.new("Change not acceptable in boxfill phase for '#{article.name}', sorry.",
                                             self)
    end
  end

  def _missing_units(unit_quantity, quantity, tolerance)
    units = unit_quantity - ((quantity % unit_quantity) + tolerance)
    units = 0 if units < 0
    units = 0 if units == unit_quantity
    units
  end
end
