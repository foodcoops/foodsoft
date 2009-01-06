class Project < ActiveRecord::Base
  belongs_to :category
  acts_as_ordered :order => 'name', :scope => :category
end

class WrappedProject < ActiveRecord::Base
  belongs_to :category
  set_table_name :projects
  acts_as_ordered :order => 'name', :scope => :category, :wrap => true
end

class SQLScopedProject < ActiveRecord::Base
  set_table_name :projects
  acts_as_ordered :order => 'name', :scope => 'category_id = #{category_id}'
end

class WrappedSQLScopedProject < ActiveRecord::Base
  set_table_name :projects
  acts_as_ordered :order => 'name', :scope => 'category_id = #{category_id}', :wrap => true
end
