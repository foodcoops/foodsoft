class AppleBar
  attr_reader :ordergroup

  def initialize(ordergroup)
    @ordergroup = ordergroup
    @group_avg = ordergroup.avg_jobs_per_euro.to_f
    @global_avg = Ordergroup.avg_jobs_per_euro
  end

  # Show group bar in following colors:
  # Green if higher than 100
  # Yellow if lower than 100 an higher than stop_ordering_under option value
  # Red if below stop_ordering_under, the ordergroup isn't allowed to participate in an order anymore
  def group_bar_state
    if apples >= 100
      'success'
    else
      if FoodsoftConfig[:stop_ordering_under].present? and
         apples >= FoodsoftConfig[:stop_ordering_under]
        'warning'
      else
        'danger'
      end
    end
  end

  # Use apples as percentage, but show at least 10 percent
  def group_bar_width
    @ordergroup.apples < 2 ? 2 : @ordergroup.apples
  end

  def mean_order_amount_per_job
    (1 / @global_avg).round rescue 0
  end

  def apples
    @apples ||= @ordergroup.apples
  end

  def with_restriction?
    FoodsoftConfig[:stop_ordering_under].present?
  end
end
