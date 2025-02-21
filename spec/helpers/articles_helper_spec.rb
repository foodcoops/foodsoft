require_relative '../spec_helper'

describe ArticlesHelper do
  include described_class

  let(:article) { create(:article) }
  let(:article_version) { article.latest_article_version }

  describe 'formatting supplier order unit' do
    def test_with_article_data(supplier_order_unit: nil, group_order_unit: nil, ratios: nil)
      setup_article_version(supplier_order_unit: supplier_order_unit, group_order_unit: group_order_unit, ratios: ratios)
      format_supplier_order_unit_with_ratios(article_version).gsub(Prawn::Text::NBSP, ' ')
    end

    describe 'without ratios' do
      it 'formats SI conversible unit without ratios' do
        result = test_with_article_data(supplier_order_unit: 'KGM')
        expect(result).to eq('kg')
      end

      it 'formats non SI conversible unit' do
        result = test_with_article_data(supplier_order_unit: 'XPK')
        expect(result).to eq('Package')
      end
    end

    describe 'with ratios' do
      it 'formats ratio to group order unit' do
        result = test_with_article_data(
          supplier_order_unit: 'XPK',
          ratios: [[250, 'GRM']],
          group_order_unit: 'GRM'
        )
        expect(result).to eq('Package (250 g)')
      end

      it 'formats ratio to first SI ratio if group order unit equals or defaults to supplier order unit' do
        result = test_with_article_data(
          supplier_order_unit: 'XPK',
          ratios: [[250, 'GRM']],
          group_order_unit: nil
        )
        expect(result).to eq('Package (250 g)')
      end

      it 'formats ratio to group order unit with multiple ratios' do
        result = test_with_article_data(
          supplier_order_unit: 'XCR',
          ratios: [[20.148, 'KGM'], [20, 'XBO'], [10, 'LTR']],
          group_order_unit: 'XBO'
        )
        expect(result).to eq('Crate (20 × 0.5 l)')
      end

      it 'formats ratio from group order unit to first SI ratio if group order unit equals or defaults to supplier order unit' do
        result = test_with_article_data(
          supplier_order_unit: 'XPX',
          ratios: [[100, 'XPC'], [400, 'XPK'], [4000, 'X6H'], [200_000, 'GRM']],
          group_order_unit: 'XPK'
        )
        expect(result).to eq('Pallet (400 × 500 g)')
      end

      it 'formats ratio from group order unit to first SI ratio' do
        result = test_with_article_data(
          supplier_order_unit: 'XPX',
          ratios: [[100, 'XPC'], [400, 'XPK'], [4000, 'X6H'], [200_000, 'GRM']],
          group_order_unit: 'KGM'
        )
        expect(result).to eq('Pallet (200 kg)')
      end
    end
  end

  describe 'formatting group order unit' do
    def test_with_article_data(supplier_order_unit: nil, group_order_unit: nil, ratios: nil)
      setup_article_version(supplier_order_unit: supplier_order_unit, group_order_unit: group_order_unit, ratios: ratios)
      format_group_order_unit_with_ratios(article_version).gsub(Prawn::Text::NBSP, ' ')
    end

    describe 'without ratios' do
      it 'formats SI conversible unit without ratios' do
        result = test_with_article_data(supplier_order_unit: 'KGM', group_order_unit: 'KGM')
        expect(result).to eq('kg')
      end

      it 'formats non SI conversible unit' do
        result = test_with_article_data(supplier_order_unit: 'XPK', group_order_unit: 'XPK')
        expect(result).to eq('Package')
      end
    end

    describe 'with ratios' do
      it 'formats group order unit without ratios if group order unit is SI conversible' do
        result = test_with_article_data(
          supplier_order_unit: 'XPK',
          ratios: [[250, 'GRM']],
          group_order_unit: 'GRM'
        )
        expect(result).to eq('g')
      end

      it 'formats group order unit with ratio to first SI unit if group order unit is not SI conversible' do
        result = test_with_article_data(
          supplier_order_unit: 'XCR',
          ratios: [[20.148, 'KGM'], [20, 'XBO'], [10, 'LTR']],
          group_order_unit: 'XBO'
        )
        expect(result).to eq('Bottle (0.5 l)')
      end
    end
  end
end

private

def setup_article_version(supplier_order_unit:, ratios:, group_order_unit:)
  article_version.supplier_order_unit = supplier_order_unit unless supplier_order_unit.nil?
  unless ratios.nil?
    article_version.article_unit_ratios = ratios.each_with_index.map do |ratio_data, index|
      ArticleUnitRatio.create(sort: index, quantity: ratio_data[0], unit: ratio_data[1])
    end
  end
  article_version.group_order_unit = group_order_unit unless group_order_unit.nil?
end
