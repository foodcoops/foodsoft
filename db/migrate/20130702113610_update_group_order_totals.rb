class UpdateGroupOrderTotals < ActiveRecord::Migration
  def self.up
    # The group_order total was updated to the total ordered amount instead of
    # the amount received. Now this is fixed, the totals need to be updated.
    GroupOrder.all.each do |go|
      go.order.closed? and go.update_price!
    end
  end

  def self.down
  end
end
