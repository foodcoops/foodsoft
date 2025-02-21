require_relative '../spec_helper'

describe ArticleVersion do
  let(:admin) { create(:user, groups: [create(:workgroup, role_finance: true)]) }
  let(:user) { create(:user, groups: [create(:ordergroup)]) }
  let(:order) { create(:order, article_count: 10) }
  let(:go) { create(:group_order, order: order, ordergroup: user.ordergroup) }
  let(:goa) { create(:group_order_article, group_order: go, order_article: order.order_articles.first) }

  describe 'versioning depending on order status' do
    let(:article_version) { order.order_articles.first.article_version }
    let(:article) { article_version.article }

    it 'updates the properties of article versions in open orders in place' do
      original_version_id = article_version.id

      new_version = create(:article_version)
      new_attributes = new_version.attributes.except('updated_at', 'created_at', 'id', 'article_id')

      article.update(latest_article_version_attributes: new_attributes.merge(id: article_version.id))

      new_attributes.each do |key, value|
        expect(order.order_articles.first.article_version[key]).to eq value
      end
      expect(original_version_id).to eq article.latest_article_version.id
    end

    it 'keeps the properties of article versions in closed orders' do
      oa = order.order_articles.first
      current_article_version = oa.reload.article_version
      original_version_id = current_article_version.id
      original_version = current_article_version.dup

      new_version = create(:article_version)
      new_attributes = new_version.attributes.except('updated_at', 'created_at', 'id', 'article_id')

      order.finish!(admin)

      article.update(latest_article_version_attributes: new_attributes.merge(id: article_version.id))

      new_version = article.latest_article_version
      version_in_order = oa.reload.article_version

      expect(original_version_id).not_to eq new_version.id
      expect(original_version_id).to eq version_in_order.id
      new_attributes.each do |key, value|
        expect(new_version[key]).to eq value
        expect(version_in_order[key]).to eq(original_version[key])
      end
    end
  end

  describe 'validates that there\'s only one kind of supplier order unit: old plain text or new un ece' do
    let(:article_version) { order.order_articles.first.article_version }
    let(:article) { article_version.article }

    it 'prevents setting both fields' do
      update_result = article.update(latest_article_version_attributes: { unit: 'kg', supplier_order_unit: 'KGM', id: article_version.id })
      expect(update_result).to be false
      expect(article.latest_article_version.errors.first.type).to eq :invalid
      expect(article.latest_article_version.errors.first.attribute).to eq :unit
    end

    it 'allows setting just the new field' do
      update_result = article.update(latest_article_version_attributes: { unit: '', supplier_order_unit: 'KGM', id: article_version.id })
      expect(update_result).to be true
      expect(article.unit).to be_nil
    end
  end

  describe 'unit conversion' do
    let(:article_version) { order.order_articles.first.article_version }

    it 'allows converting SI units' do
      article_version.supplier_order_unit = 'KGM'
      article_version.article_unit_ratios = []
      article_version.save

      result = article_version.convert_quantity(3000, 'GRM', 'KGM')
      expect(result).to eq 3
    end

    it 'allows converting SI units with non-supplier-units' do
      article_version.supplier_order_unit = 'XPP'
      article_version.article_unit_ratios = [ArticleUnitRatio.new({ sort: 0, unit: 'KGM', quantity: 1 })]
      article_version.save

      result = article_version.convert_quantity(2000, 'GRM', 'KGM')
      expect(result).to eq 2
    end

    it 'allows converting piece units if ratios are defined accordingly' do
      article_version.supplier_order_unit = 'XCR'
      article_version.article_unit_ratios = [
        ArticleUnitRatio.new({ sort: 0, unit: 'XBO', quantity: 20 }),
        ArticleUnitRatio.new({ sort: 1, unit: 'LTR', quantity: 10 })
      ]
      article_version.save

      result = article_version.convert_quantity(10, 'XBO', 'XCR')
      expect(result).to eq 0.5

      result = article_version.convert_quantity(10, 'XBO', 'LTR')
      expect(result).to eq 5

      result = article_version.convert_quantity(10, 'LTR', 'XCR')
      expect(result).to eq 1
    end

    it 'raises an error when trying to do convert to piece units for which no ratios exist' do
      article_version.supplier_order_unit = 'XCR'
      article_version.article_unit_ratios = [
        ArticleUnitRatio.new({ sort: 0, unit: 'XBO', quantity: 20 }),
        ArticleUnitRatio.new({ sort: 1, unit: 'LTR', quantity: 10 })
      ]
      article_version.save

      expect { article_version.convert_quantity(10, 'XBO', 'KGM') }.to raise_error(PriceCalculation::UnsupportedUnitConversionError)
    end

    it 'raises an error when trying to do convert to or from non-existant units' do
      article_version.supplier_order_unit = 'XCR'
      article_version.article_unit_ratios = [
        ArticleUnitRatio.new({ sort: 0, unit: 'XBO', quantity: 20 }),
        ArticleUnitRatio.new({ sort: 1, unit: 'LTR', quantity: 10 })
      ]
      article_version.save

      expect { article_version.convert_quantity(10, 'LTR', 'non-existant') }.to raise_error(PriceCalculation::UnsupportedUnitConversionError)
      expect { article_version.convert_quantity(10, 'non-existant', 'LTR') }.to raise_error(PriceCalculation::UnsupportedUnitConversionError)
    end
  end

  describe 'validate unique name for latest article versions' do
    let(:first_article_version) { order.order_articles.first.article_version }
    let(:first_article) { first_article_version.article }

    let(:second_article_version) { order.order_articles.second.article_version }
    let(:second_article) { second_article_version.article }

    it 'prevents updating the name of the latest article version to the same as another current article name' do
      update_result = second_article.update(latest_article_version_attributes: { name: first_article_version.name, id: second_article_version.id })
      expect(update_result).to be false
      expect(second_article.latest_article_version.errors.first.type).to eq :taken
      expect(second_article.latest_article_version.errors.first.attribute).to eq :name
    end

    it 'allows updating the name of the latest article version to the same as another article version\'s name as long as that version is obsolete' do
      order.finish!(admin)

      original_first_article_name = first_article_version.name
      first_article.update(latest_article_version_attributes: { name: 'new name', id: first_article_version.id })

      update_result = second_article.update(latest_article_version_attributes: { name: original_first_article_name, id: second_article_version.id })
      expect(update_result).to be true

      number_of_articles_with_same_name = described_class
                                          .includes(:article)
                                          .where(
                                            name: original_first_article_name,
                                            articles: { supplier_id: order.supplier.id }
                                          )
                                          .count
      expect(number_of_articles_with_same_name).to eq 2
    end

    it 'still allow updating attributes including name if name stays the same' do
      update_result = second_article.update(latest_article_version_attributes: { name: second_article_version.name, price: 2, id: second_article_version.id })
      expect(update_result).to be true
      expect(second_article.latest_article_version.price).to eq 2
    end

    describe 'articles in suppliers with shared_sync_method = all*' do
      let(:supplier) { create(:supplier, shared_sync_method: 'all_available', supplier_remote_source: 'https://dummy.com') }
      let(:first_article) { create(:article, supplier: supplier, name: 'One') }
      let(:second_article) { create(:article, supplier: supplier, name: 'Two') }
      let(:order) { create(:order, supplier: supplier, article_ids: [first_article.id, second_article.id]) }

      it 'allows updating the name of the latest article version to the same as another current article name if they have different supplier and group order units' do
        first_article_version.supplier_order_unit = 'XPP'
        first_article_version.group_order_unit = 'GRM'
        first_article_version.article_unit_ratios = [ArticleUnitRatio.new({ sort: 0, unit: 'KGM', quantity: 1 })]
        first_article_version.save
        second_article_version.supplier_order_unit = 'XPP'
        second_article_version.group_order_unit = 'GRM'
        second_article_version.article_unit_ratios = [ArticleUnitRatio.new({ sort: 0, unit: 'KGM', quantity: 2 })]
        second_article_version.save

        update_result = second_article.update(latest_article_version_attributes: { name: first_article_version.name, id: second_article_version.id })
        expect(update_result).to be true
      end

      it 'prevents updating the name of the latest article version to the same as another current article name if they have the same supplier and group order units' do
        first_article_version.supplier_order_unit = 'XPP'
        first_article_version.group_order_unit = 'GRM'
        first_article_version.article_unit_ratios = [ArticleUnitRatio.new({ sort: 0, unit: 'KGM', quantity: 1 })]
        first_article_version.save
        second_article_version.supplier_order_unit = 'XPP'
        second_article_version.group_order_unit = 'GRM'
        second_article_version.article_unit_ratios = [ArticleUnitRatio.new({ sort: 0, unit: 'KGM', quantity: 1 })]
        second_article_version.save

        update_result = second_article.update(latest_article_version_attributes: { name: first_article_version.name, id: second_article_version.id })
        expect(update_result).to be false
        expect(second_article.latest_article_version.errors.first.type).to eq :taken_with_unit
        expect(second_article.latest_article_version.errors.first.attribute).to eq :name
      end

      it 'still allow updating attributes including name if name stays the same' do
        first_article_version.supplier_order_unit = 'XPP'
        first_article_version.group_order_unit = 'GRM'
        first_article_version.article_unit_ratios = [ArticleUnitRatio.new({ sort: 0, unit: 'KGM', quantity: 1 })]
        first_article_version.save
        second_article_version.supplier_order_unit = 'XPP'
        second_article_version.group_order_unit = 'GRM'
        second_article_version.article_unit_ratios = [ArticleUnitRatio.new({ sort: 0, unit: 'KGM', quantity: 1 })]
        second_article_version.save

        update_result = second_article.update(latest_article_version_attributes: { name: second_article_version.name, price: 2, id: second_article_version.id })
        expect(update_result).to be true
        expect(second_article.latest_article_version.price).to eq 2
      end
    end
  end
end
