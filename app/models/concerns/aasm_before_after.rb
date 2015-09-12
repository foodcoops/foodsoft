# Add state comparison methods to AASM model
# @see http://stackoverflow.com/questions/26683828
module AASMBeforeAfter
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def aasm(*args, &block)
      r = super(*args, &block)
      if block
        states = r.state_machine.states.map(&:name)
        column = r.attribute_name
        states.each_with_index do |state, i|
          scope "#{state}_or_after", ->{ where(column => states[i..-1]) }
          scope "#{state}_or_before", ->{ where(column => states[0..i]) }

          define_method "#{state}_or_after?", ->{ states[i..-1].include? read_attribute(column).to_sym }
          define_method "#{state}_or_before?", ->{ states[0..i].include? read_attribute(column).to_sym }
        end
      end
      r
    end
  end
end
