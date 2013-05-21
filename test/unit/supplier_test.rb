require File.dirname(__FILE__) + '/../test_helper'

class SupplierTest < Test::Unit::TestCase
  fixtures :suppliers

  def setup
    @supplier = Supplier.find_by_name("Terra")
  end

  def test_read
    assert_equal "Terra", @supplier.name
    assert_equal "www.terra-natur.de", @supplier.url
  end
  
  def test_update
    assert_equal "tuesday", @supplier.delivery_days
    @supplier.delivery_days = 'wednesday'
    assert @supplier.save, @supplier.errors.full_messages.join("; ")
    @supplier.reload
    assert_equal 'wednesday', @supplier.delivery_days
  end
end

