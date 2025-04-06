# An OrderArticle represents a single Article that is part of an Order.
class OrderArticle < ApplicationRecord
  include FindEachWithOrder

  attr_reader :update_global_price

  belongs_to :order
  belongs_to :article_version
  has_many :group_order_articles, dependent: :destroy

  validates :order_id, :article_version_id, presence: true
  validate :article_version_and_price_exist
  validates :article_version_id, uniqueness: { scope: :order_id }

  _ordered_sql = 'order_articles.units_to_order > 0 OR order_articles.units_billed > 0 OR order_articles.units_received > 0'
  scope :ordered, -> { where(_ordered_sql) }
  scope :ordered_or_member, lambda {
                              includes(:group_order_articles).where("#{_ordered_sql} OR order_articles.quantity > 0 OR group_order_articles.result > 0")
                            }
  scope :belonging_to_open_order, -> { joins(:order).merge(Order.open) }
  scope :belonging_to_finished_order, -> { joins(:order).merge(Order.finished) }

  # alias for old code which is hard to automatically replace (.price could also refer to ArticleVersion.price)
  alias price article_version

  before_create :init_from_balancing
  after_destroy :update_ordergroup_prices

  def self.ransackable_attributes(_auth_object = nil)
    %w[id order_id article_id quantity tolerance units_to_order]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[order article]
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
    { quantity: quantity, price: quantity * price.fc_group_order_price }
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
    return 0 if !price.minimum_order_quantity.nil? && quantity + tolerance < price.minimum_order_quantity
    return price.minimum_order_quantity if quantity > 0 && !price.minimum_order_quantity.nil? && quantity < price.minimum_order_quantity && quantity + tolerance >= price.minimum_order_quantity

    unit_size = price.convert_quantity(1, price.supplier_order_unit, price.group_order_unit)
    if price.supplier_order_unit_is_si_convertible
      quantity / unit_size
    else
      units = (quantity / unit_size).floor
      remainder = quantity % unit_size
      units += ((remainder > 0) && (remainder + tolerance >= unit_size) ? 1 : 0)
    end
  end

  # Calculate price for ordered quantity.
  def total_price
    units * price.price
  end

  # Calculate gross price for ordered qunatity.
  def total_gross_price
    units * price.gross_price
  end

  # redistribute articles over ordergroups
  #   quantity       Number of units to distribute (in group_order_unit)
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
  def update_handling_versioning!(order_article_attributes, version_attributes)
    OrderArticle.transaction do
      # Updates self
      update!(order_article_attributes)

      # Updates article_version belonging to current order article
      original_article_version = article_version.duplicate_including_article_unit_ratios
      article_version.assign_attributes(version_attributes)
      if article_version.changed?
        update_or_create_article_version(version_attributes, original_article_version)

        # Updates ordergroup values
        update_ordergroup_prices
      end
    end
  end

  def update_global_price=(value)
    @update_global_price = [true, '1'].include?(value) ? true : false
  end

  # @return [Number] Units missing for the last +unit_quantity+ of the article.
  def missing_units
    unit_ratio = price.convert_quantity(1, price.supplier_order_unit, price.group_order_unit)
    _missing_units(unit_ratio, quantity, tolerance, price.minimum_order_quantity)
  end

  def missing_units_was
    unit_ratio = price.convert_quantity(1, price.supplier_order_unit, price.group_order_unit)
    _missing_units(unit_ratio, quantity_was, tolerance_was, price.minimum_order_quantity)
  end

  # Check if the result of any associated GroupOrderArticle was overridden manually
  def result_manually_changed?
    group_order_articles.any? { |goa| goa.result_manually_changed? }
  end

  def difference_received_ordered
    (units_received || 0) - units_to_order
  end

  private

  def article_version_and_price_exist
    if !(article_version = ArticleVersion.find(article_version_id)) || article_version.fc_price.nil?
      errors.add(:article_version,
                 I18n.t('model.order_article.error_price'))
    end
  rescue StandardError
    errors.add(:article_version, I18n.t('model.order_article.error_price'))
  end

  # Associate with current article price if created in a finished order
  def init_from_balancing
    return unless order.present? && order.finished?

    self.article_version = article_version.article.article_versions.first
  end

  def update_or_create_article_version(version_attributes, original_article_version)
    version_attributes = version_attributes.merge(article_id: article_version.article_id)

    modifying_earlier_version = article_version.article.latest_article_version.id != article_version_id
    finished_order_article_using_same_version = OrderArticle.belonging_to_finished_order.where(article_version_id: article_version_id).where.not(id: id)

    if (!update_global_price && modifying_earlier_version && !finished_order_article_using_same_version.exists?) ||
       (update_global_price && !modifying_earlier_version)
      # update in place:
      article_version.save
    else
      # create new version:
      original_version_id = article_version.id
      self.article_version = article_version.duplicate_including_article_unit_ratios
      article_version.save
      update_attribute(:article_version_id, article_version.id)

      if update_global_price
        # update open order articles:
        OrderArticle.belonging_to_open_order.where(article_version_id: original_version_id).update_all(article_version_id: article_version.id)
      else
        # create yet *another* version, wich contains the old data, so new orders will continue using that data:
        # (The checkbox "Also update the price of future orders" not being checked implies that)
        original_article_version.created_at = article_version.created_at + 1.second
        original_article_version.save
      end
    end
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
      raise ActiveRecord::RecordNotSaved.new("Change not acceptable in boxfill phase for '#{article_version.name}', sorry.",
                                             self)
    end
  end

  def _missing_units(unit_ratio, quantity, tolerance, minimum_order_quantity)
    return minimum_order_quantity - quantity - tolerance if !minimum_order_quantity.nil? && quantity > 0 && quantity + tolerance < minimum_order_quantity

    return 0 if article_version.supplier_order_unit_is_si_convertible

    units = unit_ratio - ((quantity % unit_ratio) + tolerance)

    units = 0 if units < 0
    units = 0 if units == unit_ratio
    units
  end
end
