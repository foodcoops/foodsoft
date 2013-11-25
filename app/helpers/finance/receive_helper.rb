# :encoding:utf-8:
module Finance::ReceiveHelper
  # TODO currently duplicate a bit of DeliveriesHelper.articles_for_select2
  def articles_for_select2(supplier)
    supplier.articles.undeleted.reorder('articles.name ASC').map do |a|
      {:id => a.id, :text => "#{a.name} (#{a.unit_quantity}⨯#{a.unit})"}
    end
  end
end
