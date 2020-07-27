module Faker
  class Unit
    class << self
      def unit
        ['kg', '1L', '100ml', 'piece', 'bunch', '500g'].sample
      end
    end
  end
end

