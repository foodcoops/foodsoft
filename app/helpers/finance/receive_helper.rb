# :encoding:utf-8:
module Finance::ReceiveHelper
  # TODO currently duplicate a bit of DeliveriesHelper.articles_for_select2
  # except is an array of article id's to omit
  def articles_for_select2(supplier, except = [])
    articles = supplier.articles.reorder('articles.name ASC')
    articles.reject! {|a| not except.index(a.id).nil? } if except
    articles.map do |a|
      {:id => a.id, :text => "#{a.name} (#{a.unit_quantity}⨯#{a.unit})"}
    end
  end
end
