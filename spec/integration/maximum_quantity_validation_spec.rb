require 'spec_helper'

describe 'Maximum Quantity Validation' do
  describe 'ArticleVersion' do
    let(:article_version) { create(:article_version) }

    it 'allows setting maximum_order_quantity' do
      article_version.maximum_order_quantity = 5.0
      article_version.save!

      expect(article_version.reload.maximum_order_quantity).to eq(5.0)
    end

    it 'validates maximum_order_quantity as numeric' do
      article_version.maximum_order_quantity = 'invalid'
      expect(article_version).not_to be_valid
      expect(article_version.errors[:maximum_order_quantity]).to be_present
    end

    it 'allows nil maximum_order_quantity' do
      article_version.maximum_order_quantity = nil
      expect(article_version).to be_valid
    end

    context 'minimum and maximum order quantity validation' do
      it 'allows minimum_order_quantity equal to maximum_order_quantity' do
        article_version.minimum_order_quantity = 5.0
        article_version.maximum_order_quantity = 5.0
        expect(article_version).to be_valid
      end

      it 'allows minimum_order_quantity less than maximum_order_quantity' do
        article_version.minimum_order_quantity = 3.0
        article_version.maximum_order_quantity = 5.0
        expect(article_version).to be_valid
      end

      it 'rejects minimum_order_quantity greater than maximum_order_quantity' do
        article_version.minimum_order_quantity = 10.0
        article_version.maximum_order_quantity = 5.0
        expect(article_version).not_to be_valid
        expect(article_version.errors[:minimum_order_quantity]).to include('must be less than or equal to maximum order quantity')
      end

      it 'allows validation when only minimum_order_quantity is set' do
        article_version.minimum_order_quantity = 5.0
        article_version.maximum_order_quantity = nil
        expect(article_version).to be_valid
      end

      it 'allows validation when only maximum_order_quantity is set' do
        article_version.minimum_order_quantity = nil
        article_version.maximum_order_quantity = 5.0
        expect(article_version).to be_valid
      end

      it 'allows validation when both are nil' do
        article_version.minimum_order_quantity = nil
        article_version.maximum_order_quantity = nil
        expect(article_version).to be_valid
      end
    end
  end

  describe 'GroupOrder quantity_available calculation' do
    let(:user) { create(:user, :ordergroup) }
    let(:supplier) { create(:supplier) }
    let(:article) { create(:article, supplier: supplier) }
    let(:order) { create(:order, supplier: supplier, article_ids: [article.id]) }
    let(:group_order) { create(:group_order, order: order, ordergroup: user.ordergroup) }

    context 'when article has maximum_order_quantity' do
      before do
        article.article_versions.last.update!(maximum_order_quantity: 10.0)
      end

      it 'calculates quantity_available based on maximum_order_quantity' do
        ordering_data = group_order.load_data
        order_article = order.order_articles.first

        expect(ordering_data[:order_articles][order_article.id][:quantity_available]).to eq(10.0)
      end

      it 'reduces quantity_available when other orders exist' do
        # Create another group order with some quantity
        other_group_order = create(:group_order, order: order)
        order_article = order.order_articles.first
        create(:group_order_article,
               group_order: other_group_order,
               order_article: order_article,
               quantity: 3.0)

        order_article.update_results!

        ordering_data = group_order.load_data

        available = ordering_data[:order_articles][order_article.id][:quantity_available]
        expect(available).to eq 7 # 10 - 3 = 7
      end
    end
  end
end
