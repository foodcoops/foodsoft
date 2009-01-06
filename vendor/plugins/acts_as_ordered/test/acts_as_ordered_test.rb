require File.join(File.dirname(__FILE__), 'abstract_unit')

class ActsAsOrderedTest < Test::Unit::TestCase
  fixtures :cartoons
  
  def test_normal
    bugs = cartoons(:bugs)
    
    assert_equal bugs, bugs.previous
    assert_equal cartoons(:daffy), bugs.next
    
    # No wrapping
    assert_equal cartoons(:roger), bugs.next.next.next.next.next
    assert_equal bugs, bugs.next.next.next.next.next.next.previous.previous.previous.previous.previous.previous
  end
  
  def test_find_by_direction
    assert_equal cartoons(:bugs), cartoons(:bugs).find_by_direction(:previous)
    
    assert_equal cartoons(:daffy), cartoons(:bugs).find_by_direction(:next)
    assert_equal cartoons(:roger), cartoons(:bugs).find_by_direction(:next, :number => 5)
    
    assert_raises(ActiveRecord::Acts::Ordered::InvalidDirection) { cartoons(:bugs).find_by_direction('destroy') }
  end
  
  def test_insert_and_remove
    bugs, daffy = cartoons(:bugs), cartoons(:daffy)
    
    assert_equal daffy, bugs.next
    cat = Cartoon.create(:first_name => 'Cat', :last_name => 'in the Hat')
    assert_equal cat, bugs.next
    assert_equal daffy, bugs.next.next
    
    assert_equal cat, daffy.previous
    assert cat.destroy
    assert_equal bugs, daffy.previous
  end
  
  def test_desc_order
    bugs = reversed_cartoons(:bugs)
    
    assert_equal bugs, bugs.next
    assert_equal reversed_cartoons(:daffy), bugs.previous
  end
  
  def test_with_wrapping
    elmer = wrapped_cartoons(:elmer)
    
    assert_equal wrapped_cartoons(:roger), elmer.next
    assert_equal wrapped_cartoons(:roger), elmer.previous.previous.previous
    
    assert_equal wrapped_cartoons(:bugs), elmer.next.next
    assert_equal wrapped_cartoons(:bugs), elmer.previous.previous
  end
  
  def test_jump_multiple_no_wrapping
    daffy = cartoons(:daffy)
    
    assert_equal cartoons(:roger), daffy.next(:number => 2)
    assert_equal cartoons(:roger), daffy.next(:number => 100)
    assert_equal cartoons(:bugs), daffy.previous(:number => 10)
  end
  
  def test_jump_multiple_with_wrapping
    roger = wrapped_cartoons(:roger)
    
    assert_equal roger, roger.previous(:number => 4)
    assert_equal roger, roger.next(:number => 4)
    
    assert_equal wrapped_cartoons(:elmer), roger.previous(:number => 9)
    assert_equal wrapped_cartoons(:bugs), roger.next(:number => 13)
  end
  
  def test_with_condition
    elmer = silly_cartoons(:elmer)
    
    assert_equal silly_cartoons(:roger), elmer.next
    assert_equal silly_cartoons(:roger), elmer.next(:number => 10)
    assert_equal silly_cartoons(:elmer), elmer.previous
    assert_equal silly_cartoons(:elmer), elmer.previous(:number => 3)
  end
  
  def test_with_condition_and_wrapping
    bugs = funny_cartoons(:bugs)
    
    assert_equal funny_cartoons(:daffy), bugs.next
    assert_equal funny_cartoons(:elmer), bugs.next.next
    assert_equal funny_cartoons(:bugs), bugs.next.next.next
    assert_equal funny_cartoons(:bugs), bugs.next(:number => 3)
    
    assert_equal funny_cartoons(:elmer), bugs.previous
    assert_equal funny_cartoons(:daffy), bugs.previous(:number => 3)
  end
  
  def test_current_index_and_position
    assert_equal 0, cartoons(:bugs).current_index
    assert_equal 1, cartoons(:bugs).current_position
    assert_equal 1, cartoons(:daffy).current_index
    assert_equal 2, cartoons(:daffy).current_position
    assert_equal 2, cartoons(:bugs).next.current_position
    assert_equal 4, cartoons(:bugs).last.current_position
    assert_equal 4, cartoons(:roger).current_position
  end
  
  def test_current_total
    assert_equal 4, cartoons(:bugs).current_total
  end
  
 private
  def find_cartoon(name, klass)
    klass.find(cartoons(name).id)
  end
  
  def wrapped_cartoons(name)
    find_cartoon(name, WrappedCartoon)
  end
  
  def reversed_cartoons(name)
    find_cartoon(name, ReversedCartoon)
  end
  
  def funny_cartoons(name)
    find_cartoon(name, FunnyCartoon)
  end
  
  def silly_cartoons(name)
    find_cartoon(name, SillyCartoon)
  end
end

class ActsAsOrderedWithScopeTest < Test::Unit::TestCase
  fixtures :categories, :projects
  
  def test_first_and_last_a
    assert projects(:one).first?
    assert projects(:three).last?
    assert_equal 1, projects(:two).first_id
    assert_equal 3, projects(:two).last_id
    assert_equal projects(:one), projects(:one).first
    assert_equal projects(:three), projects(:one).last
    assert_equal projects(:one), projects(:two).first
    assert_equal projects(:three), projects(:two).last
    assert_equal projects(:one), projects(:three).first
    assert_equal projects(:three), projects(:three).last
  end
  
  def test_first_and_last_b
    assert projects(:four).first?
    assert projects(:seven).last?
    assert_equal 4, projects(:five).first_id
    assert_equal 7, projects(:five).last_id
    assert_equal projects(:four), projects(:four).first
    assert_equal projects(:seven), projects(:four).last
    assert_equal projects(:four), projects(:five).first
    assert_equal projects(:seven), projects(:five).last
    assert_equal projects(:four), projects(:six).first
    assert_equal projects(:seven), projects(:six).last
    assert_equal projects(:four), projects(:seven).first
    assert_equal projects(:seven), projects(:seven).last
  end
    
  def test_symbol_scope_no_wrapping_a
    one = projects(:one)
    assert projects(:one).first?
    assert projects(:three).last?
    assert_equal one, one.previous
    assert_equal one, one.next.previous
    assert_equal projects(:two), one.next
    assert_equal projects(:three), projects(:three).next
    assert_equal projects(:three), one.next.next
    assert_equal projects(:three), one.next.next.next
    assert_equal projects(:three), one.next.next.next.next
  end
  
  def test_symbol_scope_no_wrapping_b
    assert projects(:four).first?
    assert projects(:seven).last?
    assert_equal projects(:four), projects(:four).previous
    assert_equal projects(:five), projects(:four).next
    assert_equal projects(:six), projects(:five).next
    assert_equal projects(:seven), projects(:six).next
    assert_equal projects(:seven), projects(:seven).next
  end
  
  def test_symbol_scope_and_wrapping_a
    one = wrapped_projects(:one)
    assert wrapped_projects(:one).first?
    assert wrapped_projects(:three).last?
    assert_equal wrapped_projects(:three), one.previous
    assert_equal wrapped_projects(:one), wrapped_projects(:one).next.previous
    assert_equal wrapped_projects(:two), wrapped_projects(:one).next
    assert_equal wrapped_projects(:three), wrapped_projects(:two).next
    assert_equal wrapped_projects(:three), wrapped_projects(:one).next.next
    assert_equal wrapped_projects(:one), wrapped_projects(:three).next
  end

  def test_symbol_scope_and_wrapping_b
    assert wrapped_projects(:four).first?
    assert wrapped_projects(:seven).last?
    assert_equal wrapped_projects(:seven), wrapped_projects(:four).previous
    assert_equal wrapped_projects(:five), wrapped_projects(:four).next
    assert_equal wrapped_projects(:six), wrapped_projects(:five).next
    assert_equal wrapped_projects(:seven), wrapped_projects(:six).next
    assert_equal wrapped_projects(:four), wrapped_projects(:seven).next
  end

  def test_sql_scope_no_wrapping
    one = sql_scoped_projects(:one)
    assert sql_scoped_projects(:one).first?
    assert sql_scoped_projects(:three).last?
    assert_equal one, one.previous
    assert_equal one, one.next.previous
    assert_equal sql_scoped_projects(:two), one.next
    assert_equal sql_scoped_projects(:three), sql_scoped_projects(:three).next
    assert_equal sql_scoped_projects(:three), one.next.next
    assert_equal sql_scoped_projects(:three), one.next.next.next
    assert_equal sql_scoped_projects(:three), one.next.next.next.next
  end

  def test_sql_scope_and_wrapping
    one = wrapped_sql_scoped_projects(:one)
    assert wrapped_sql_scoped_projects(:one).first?
    assert wrapped_sql_scoped_projects(:three).last?
    assert_equal wrapped_sql_scoped_projects(:three), one.previous
    assert_equal wrapped_sql_scoped_projects(:one), wrapped_sql_scoped_projects(:one).next.previous
    assert_equal wrapped_sql_scoped_projects(:two), wrapped_sql_scoped_projects(:one).next
    assert_equal wrapped_sql_scoped_projects(:three), wrapped_sql_scoped_projects(:two).next
    assert_equal wrapped_sql_scoped_projects(:three), wrapped_sql_scoped_projects(:one).next.next
    assert_equal wrapped_sql_scoped_projects(:one), wrapped_sql_scoped_projects(:three).next
  end
  
  def test_current_total
    assert_equal 3, projects(:one).current_total
    assert_equal 4, projects(:four).current_total
  end
  
  def test_with_options
    project = wrapped_projects(:one).next(:include => :category)
    assert project.instance_variable_get('@category')
  end
  
 private
  def find_project(name, klass)
    klass.find(projects(name).id)
  end
  
  def wrapped_projects(name)
    find_project(name, WrappedProject)
  end
  
  def sql_scoped_projects(name)
    find_project(name, SQLScopedProject)
  end
  
  def wrapped_sql_scoped_projects(name)
    find_project(name, WrappedSQLScopedProject)
  end
end

class ActsAsOrderedStiTest < Test::Unit::TestCase
  fixtures :documents
  
  def test_subclasses
    assert_equal documents(:entry_2), documents(:entry_1).next
    assert_equal documents(:entry_3), documents(:entry_2).next
    assert_equal documents(:entry_2), documents(:entry_3).previous
    assert_equal documents(:entry_1), documents(:entry_2).previous
    
    assert_equal documents(:page_2), documents(:page_1).next
    assert_equal documents(:page_1), documents(:page_2).previous
  end
  
  def test_subclasses_without_sti_scoping
    Document._acts_as_ordered_options[:ignore_sti] = true
    
    assert_equal documents(:page_1), documents(:entry_2).next
    assert_equal documents(:page_2), documents(:document_2).previous
  ensure
    Document._acts_as_ordered_options.delete(:ignore_sti)
  end
end