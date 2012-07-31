class TestUser < ActiveRecord::Base

  acts_as_configurable
  
end



class TestGroup < ActiveRecord::Base
  
  acts_as_configurable
  acts_as_configurable_target

end
