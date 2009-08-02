# == Schema Information
#
# Table name: suppliers
#
#  id                 :integer(4)      not null, primary key
#  name               :string(255)     default(""), not null
#  address            :string(255)     default(""), not null
#  phone              :string(255)     default(""), not null
#  phone2             :string(255)
#  fax                :string(255)
#  email              :string(255)
#  url                :string(255)
#  contact_person     :string(255)
#  customer_number    :string(255)
#  delivery_days      :string(255)
#  order_howto        :string(255)
#  note               :string(255)
#  shared_supplier_id :integer(4)
#  min_order_quantity :string(255)
#  deleted_at         :datetime
#

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
