module FoodsoftDateUtil
  # find next occurence given a recurring ical string and time
  def self.next_occurrence(start = Time.now, from = start, options = {})
    occ = nil
    if options && options[:recurr]
      schedule = IceCube::Schedule.new(start)
      schedule.add_recurrence_rule rule_from(options[:recurr])
      # @todo handle ical parse errors
      occ = (schedule.next_occurrence(from).to_time rescue nil)
    end
    if options && options[:time] && occ
      occ = occ.beginning_of_day.advance(seconds: Time.parse(options[:time]).seconds_since_midnight)
    end
    occ
  end

  # @param p [String, Symbol, Hash, IceCube::Rule] What to return a rule from.
  # @return [IceCube::Rule] Recurring rule
  def self.rule_from(p)
    if p.is_a? String
      IceCube::Rule.from_ical(p)
    elsif p.is_a? Hash
      IceCube::Rule.from_hash(p)
    else
      p
    end
  end
end
