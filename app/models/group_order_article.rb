# == Schema Information
# Schema version: 20090120184410
#
# Table name: group_order_articles
#
#  id               :integer         not null, primary key
#  group_order_id   :integer         default(0), not null
#  order_article_id :integer         default(0), not null
#  quantity         :integer         default(0), not null
#  tolerance        :integer         default(0), not null
#  updated_on       :datetime        not null
#  result           :integer
#

# A GroupOrderArticle stores the sum of how many items of an OrderArticle are ordered as part of a GroupOrder.
# The chronologically order of the Ordergroup - activity are stored in GroupOrderArticleQuantity
#
class GroupOrderArticle < ActiveRecord::Base
  extend ActiveSupport::Memoizable    # Ability to cache method results. Use memoize :expensive_method

  belongs_to :group_order
  belongs_to :order_article
  has_many   :group_order_article_quantities, :dependent => :destroy

  validates_presence_of :group_order_id, :order_article_id
  validates_inclusion_of :quantity, :in => 0..99
  validates_inclusion_of :tolerance, :in => 0..99
  validates_uniqueness_of :order_article_id, :scope => :group_order_id    # just once an article per group order

  attr_accessor :ordergroup_id  # To create an new GroupOrder if neccessary

  named_scope :ordered, :conditions => 'result > 0'
  
  # Updates the quantity/tolerance for this GroupOrderArticle by updating both GroupOrderArticle properties 
  # and the associated GroupOrderArticleQuantities chronologically.
  # 
  # See description of the ordering algorithm in the general application documentation for details.
  def update_quantities(quantity, tolerance)
    logger.debug("GroupOrderArticle[#{id}].update_quantities(#{quantity}, #{tolerance})")
    logger.debug("Current quantity = #{self.quantity}, tolerance = #{self.tolerance}")
    
    # Get quantities ordered with the newest item first.
    quantities = group_order_article_quantities.find(:all, :order => 'created_on desc')
    logger.debug("GroupOrderArticleQuantity items found: #{quantities.size}")

    if (quantities.size == 0) 
      # There is no GroupOrderArticleQuantity item yet, just insert with desired quantities...
      logger.debug("No quantities entry at all, inserting a new one with the desired quantities")
      quantities.push(GroupOrderArticleQuantity.new(:group_order_article => self, :quantity => quantity, :tolerance => tolerance))
      self.quantity, self.tolerance = quantity, tolerance      
    else    
      # Decrease quantity/tolerance if necessary by going through the existing items and decreasing their values...
      i = 0
      while (i < quantities.size && (quantity < self.quantity || tolerance < self.tolerance))
        logger.debug("Need to decrease quantities for GroupOrderArticleQuantity[#{quantities[i].id}]")
        if (quantity < self.quantity && quantities[i].quantity > 0)
          delta = self.quantity - quantity
          delta = (delta > quantities[i].quantity ? quantities[i].quantity : delta)
          logger.debug("Decreasing quantity by #{delta}")
          quantities[i].quantity -= delta
          self.quantity -= delta        
        end
        if (tolerance < self.tolerance && quantities[i].tolerance > 0)
          delta = self.tolerance - tolerance
          delta = (delta > quantities[i].tolerance ? quantities[i].tolerance : delta)
          logger.debug("Decreasing tolerance by #{delta}")
          quantities[i].tolerance -= delta
          self.tolerance -= delta        
        end
        i += 1
      end      
      # If there is at least one increased value: insert a new GroupOrderArticleQuantity object
      if (quantity > self.quantity || tolerance > self.tolerance)
        logger.debug("Inserting a new GroupOrderArticleQuantity")
        quantities.insert(0, GroupOrderArticleQuantity.new(
          :group_order_article => self, 
          :quantity => (quantity > self.quantity ? quantity - self.quantity : 0), 
          :tolerance => (tolerance > self.tolerance ? tolerance - self.tolerance : 0)
        ))
        # Recalc totals:
        self.quantity += quantities[0].quantity
        self.tolerance += quantities[0].tolerance            
      end
    end
      
    # Check if something went terribly wrong and quantites have not been adjusted as desired.
    if (self.quantity != quantity || self.tolerance != tolerance)
      raise 'Invalid state: unable to update GroupOrderArticle/-Quantities to desired quantities!'
    end

    # Remove zero-only items.
    quantities = quantities.reject { | q | q.quantity == 0 && q.tolerance == 0}
    
    # Save
    transaction do
      quantities.each { | i | i.save! }
      self.group_order_article_quantities = quantities
      save!
    end
  end
  
  # Determines how many items of this article the Ordergroup receives.
  # Returns a hash with three keys: :quantity / :tolerance / :total
  # 
  # See description of the ordering algorithm in the general application documentation for details.
  def calculate_result
    quantity = tolerance = 0
    stockit = order_article.article.is_a?(StockArticle)

    # Get total
    total = stockit ? order_article.article.quantity : order_article.units_to_order * order_article.price.unit_quantity
    logger.debug("<#{order_article.article.name}>.unitsToOrder => items ordered: #{order_article.units_to_order} => #{total}")
       
    if (total > 0)
      # In total there are enough units ordered. Now check the individual result for the ordergroup (group_order).
      #
      # Get all GroupOrderArticleQuantities for this OrderArticle...
      order_quantities = GroupOrderArticleQuantity.all(
        :conditions => ["group_order_article_id IN (?)", order_article.group_order_article_ids], :order => 'created_on')
      logger.debug("GroupOrderArticleQuantity records found: #{order_quantities.size}")
        
      # Determine quantities to be ordered...
      total_quantity = i = 0
      while (i < order_quantities.size && total_quantity < total)
        q = (order_quantities[i].quantity <= total - total_quantity ? order_quantities[i].quantity : total - total_quantity)
        total_quantity += q
        if (order_quantities[i].group_order_article_id == self.id)
          logger.debug("increasing quantity by #{q}")
          quantity += q
        end
        i += 1
      end

      # Determine tolerance to be ordered...
      if (total_quantity < total)
        logger.debug("determining additional items to be ordered from tolerance")
        i = 0
        while (i < order_quantities.size && total_quantity < total)
          q = (order_quantities[i].tolerance <= total - total_quantity ? order_quantities[i].tolerance : total - total_quantity)
          total_quantity += q
          if (order_quantities[i].group_order_article_id == self.id)
            logger.debug("increasing tolerance by #{q}")
            tolerance += q
          end
          i += 1
        end
      end
      
      logger.debug("determined quantity/tolerance/total: #{quantity} / #{tolerance} / #{quantity + tolerance}")
    end
    
    {:quantity => quantity, :tolerance => tolerance, :total => quantity + tolerance}
  end
  memoize :calculate_result

  # Returns order result,
  # either calcualted on the fly or fetched from result attribute
  # Result is set when finishing the order.
  def result(type = :total)
    self[:result] || calculate_result[type]
  end

  # This is used during order.finish!.
  def save_results!
    self.update_attribute(:result, calculate_result[:total])
  end
  
end
