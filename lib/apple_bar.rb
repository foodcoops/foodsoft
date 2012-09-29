class AppleBar

  BAR_MAX_WITH = 600

  def initialize(ordergroup)
    @ordergroup = ordergroup
    @group_avg = ordergroup.avg_jobs_per_euro.to_f
    @global_avg = Ordergroup.avg_jobs_per_euro
  end

  def length_of_global_bar
    BAR_MAX_WITH / 2.0
  end

  def length_of_group_bar
    length = (@group_avg / @global_avg) * length_of_global_bar
    length > BAR_MAX_WITH ? BAR_MAX_WITH : length
  end

  # Show group bar in following colors:
  # Green if higher than 100
  # Yellow if lower than 100 an higher than stop_ordering_under option value
  # Red if below stop_ordering_under, the ordergroup isn't allowed to participate in an order anymore
  def group_bar_color
    if apples >= 100
      "#78b74e"
    else
      if FoodsoftConfig[:stop_ordering_under].present? and
          apples >= FoodsoftConfig[:stop_ordering_under]
        'yellow'
      else
        'red'
      end
    end
  end

  def mean_order_amount_per_job
    (1/@global_avg).round
  end

  def apples
    @apples ||= @ordergroup.apples
  end

  def with_restriction?
    FoodsoftConfig[:stop_ordering_under].present?
  end
end