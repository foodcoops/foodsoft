# A GroupOrderArticle stores the sum of how many items of an OrderArticle are ordered as part of a GroupOrder.
# The chronologically order of the OrderGroup - activity are stored in GroupOrderArticleQuantity
# 
# Properties:
# * group_order_id (int): association to the GroupOrder
# * order_article_id (int): association to the OrderArticle
# * quantity (int): number of items ordered
# * tolerance (int): number of items ordered as tolerance
# * updated_on (timestamp): updated automatically by ActiveRecord
#
class GroupOrderArticle < ActiveRecord::Base
  # gettext-option
  untranslate_all
  
  belongs_to :group_order
  belongs_to :order_article
  has_many   :group_order_article_quantities, :dependent => :destroy

  validates_presence_of :group_order_id
  validates_presence_of :order_article_id
  validates_inclusion_of :quantity, :in => 0..99
  validates_inclusion_of :tolerance, :in => 0..99
  validates_uniqueness_of :order_article_id, :scope => :group_order_id    # just once an article per group order

  # Updates the quantity/tolerance for this GroupOrderArticle by updating both GroupOrderArticle properties 
  # and the associated GroupOrderArticleQuantities chronologically.
  # 
  # See description of the ordering algorithm in the general application documentation for details.
  def updateQuantities(quantity, tolerance)
    logger.debug("GroupOrderArticle[#{id}].updateQuantities(#{quantity}, #{tolerance})")
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
  
  # Determines how many items of this article the OrderGroup receives.
  # Returns a hash with three keys: :quantity / :tolerance / :total
  # 
  # See description of the ordering algorithm in the general application documentation for details.
  def orderResult
    quantity = tolerance = 0
  
    # Get total
    total = order_article.units_to_order * order_article.article.unit_quantity
    logger.debug("unitsToOrder => items ordered: #{order_article.units_to_order} => #{total}")
       
    if (total > 0)
      # Get all GroupOrderArticleQuantities for this OrderArticle...
      orderArticles = GroupOrderArticle.find(:all, :conditions => ['order_article_id = ? AND group_order_id IN (?)', order_article.id, group_order.order.group_orders.collect { | o | o.id }])
      orderQuantities = GroupOrderArticleQuantity.find(:all, :conditions => ['group_order_article_id IN (?)', orderArticles.collect { | i | i.id }], :order => 'created_on')
      logger.debug("GroupOrderArticleQuantity records found: #{orderQuantities.size}")
        
      # Determine quantities to be ordered...
      totalQuantity = i = 0
      while (i < orderQuantities.size && totalQuantity < total)
        q = (orderQuantities[i].quantity <= total - totalQuantity ? orderQuantities[i].quantity : total - totalQuantity)
        totalQuantity += q
        if (orderQuantities[i].group_order_article_id == self.id)
          logger.debug("increasing quantity by #{q}")
          quantity += q
        end
        i += 1
      end
      
      # Determine tolerance to be ordered...
      if (totalQuantity < total)
        logger.debug("determining additional items to be ordered from tolerance")
        i = 0
        while (i < orderQuantities.size && totalQuantity < total)
          q = (orderQuantities[i].tolerance <= total - totalQuantity ? orderQuantities[i].tolerance : total - totalQuantity)
          totalQuantity += q
          if (orderQuantities[i].group_order_article_id == self.id)
            logger.debug("increasing tolerance by #{q}")
            tolerance += q
          end
          i += 1
        end        
      end
      
      # calculate the sum of quantity and tolerance:
      sum = quantity + tolerance
      
      logger.debug("determined quantity/tolerance/total: #{quantity} / #{tolerance} / #{sum}")
    end
    
    {:quantity => quantity, :tolerance => tolerance, :total => sum}
  end

end
