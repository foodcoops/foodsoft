require_relative '../spec_helper'

describe OrderTxt do
  let(:user) { create(:user, groups: [create(:ordergroup)]) }
  let(:order) { create(:order, created_by: user, starts: Date.yesterday, ends: 1.hour.ago, end_action: :auto_close, article_count: 3) }
  let(:supplier) { order.supplier }
  let(:go) { create(:group_order, order: order, ordergroup: user.ordergroup) }
  let(:articles) { order.articles }
  let(:order_articles) { order.order_articles }
  let(:first_article_version) { articles.first.latest_article_version }
  let(:second_article_version) { articles.second.latest_article_version }
  let(:third_article_version) { articles.third.latest_article_version }

  it 'creates a proper csv table sorted by order_number from an order' do
    first_article_version.update(name: 'Short name', supplier_order_unit: 'XPK')
    second_article_version.update(name: 'Much longer complicated name', supplier_order_unit: 'KGM')
    third_article_version.update(name: 'Quite short name', supplier_order_unit: 'GRM')
    order_articles.where(article_version: first_article_version).update(units_to_order: 1)
    order_articles.where(article_version: second_article_version).update(units_to_order: 1.421)
    order_articles.where(article_version: third_article_version).update(units_to_order: 4.432643311)

    result = described_class.new(order).to_txt
    expected_table = %(
Number Amount Unit    Name
0           1 Package Short name
1       1.421 kg      Much longer complicated name
2       4.433 g       Quite short name
    )
    expect(result.strip).to end_with(expected_table.strip)
  end

  it 'omits the order_number column and sort alphabetically if none of the ordered articles have an order_number' do
    first_article_version.update(name: 'Short name', supplier_order_unit: 'XPK', order_number: nil)
    second_article_version.update(name: 'Much longer complicated name', supplier_order_unit: 'KGM', order_number: nil)
    third_article_version.update(name: 'Quite short name', supplier_order_unit: 'GRM', order_number: nil)
    order_articles.where(article_version: first_article_version).update(units_to_order: 1)
    order_articles.where(article_version: second_article_version).update(units_to_order: 1.421)
    order_articles.where(article_version: third_article_version).update(units_to_order: 4.432643311)

    result = described_class.new(order).to_txt
    expected_table = %(
Amount Unit    Name
 1.421 kg      Much longer complicated name
 4.433 g       Quite short name
     1 Package Short name
    )
    expect(result.strip).to end_with(expected_table.strip)
  end
end
