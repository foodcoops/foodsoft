module FoodsoftDateUtil
  # find next occurence given a recurring ical string and time
  def self.next_occurrence(start = Time.now, from = start, options = {})
    occ = nil
    if options && options[:recurr]
      schedule = IceCube::Schedule.new(start)
      schedule.add_recurrence_rule rule_from(options[:recurr])
      # @todo handle ical parse errors
      occ = begin
        schedule.next_occurrence(from).to_time
      rescue StandardError
        nil
      end
    end
    occ = occ.beginning_of_day.advance(seconds: Time.parse(options[:time]).seconds_since_midnight) if options && options[:time] && occ
    occ
  end

  # @param rule [String, Symbol, Hash, IceCube::Rule] What to return a rule from.
  # @return [IceCube::Rule] Recurring rule
  def self.rule_from(rule)
    case rule
    when String
      IceCube::Rule.from_ical(rule)
    when Hash
      IceCube::Rule.from_hash(rule)
    when ActionController::Parameters
      IceCube::Rule.from_hash(rule.to_hash)
    else
      rule
    end
  end
end
