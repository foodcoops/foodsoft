class UpdateGroupOrderTotals < ActiveRecord::Migration[4.2]
  def self.up
    say "If you have ever modified an order after it was settled, the group_order's " +
        "price may be calculated incorrectly. This can take a lot of time on a " +
        "large database."

    say "If you do want to update the ordergroup totals, open the rails console " +
        "(by running `rails c`), and enter:"

    say "GroupOrder.all.each { |go| go.order.closed? and go.update_price! }", subitem: true

    say "You may want to check first that no undesired accounting issues are introduced. " +
        "It may be wise to discuss this with those responsible for the ordering finances."
  end

  def self.down
  end
end
