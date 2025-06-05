require_relative '../spec_helper'

describe ArticlesController do
  let(:user) { create(:user, groups: [create(:workgroup, role_article_meta: true)]) }
  let(:supplier) { create(:supplier) }
  let!(:article_category) { create(:article_category) }

  before do
    login user
  end

  describe 'POST #update_synchronized' do
    context 'with outlisted articles' do
      let!(:article_to_outlist) { create(:article, supplier: supplier) }

      it 'marks articles as deleted' do
        post_with_defaults :update_synchronized, params: {
          supplier_id: supplier.id,
          outlisted_articles: { '0' => article_to_outlist.latest_article_version.id },
          from_action: 'sync'
        }

        expect(article_to_outlist.reload.deleted?).to be true
        expect(response).to redirect_to(supplier_articles_path(supplier))
        expect(flash[:notice]).to eq I18n.t('articles.controller.update_sync.notice')
      end
    end

    context 'with updated articles' do
      let!(:article_to_update) { create(:article, supplier: supplier, name: 'Old Name') }

      it 'updates article attributes' do
        post_with_defaults :update_synchronized, params: {
          supplier_id: supplier.id,
          articles: { '0' => { id: article_to_update.latest_article_version.id, name: 'New Name' } },
          from_action: 'sync'
        }

        expect(article_to_update.reload.name).to eq 'New Name'
        expect(response).to redirect_to(supplier_articles_path(supplier))
        expect(flash[:notice]).to eq I18n.t('articles.controller.update_sync.notice')
      end
    end

    context 'with new articles' do
      it 'creates new articles' do
        expect do
          post_with_defaults :update_synchronized, params: {
            supplier_id: supplier.id,
            new_articles: {
              '0' => {
                name: 'New Article',
                article_category_id: article_category.id,
                price: 1.99,
                tax: 7,
                unit: 'kg'
              }
            },
            from_action: 'sync'
          }
        end.to change(Article, :count).by(1)

        expect(Article.last.name).to eq 'New Article'
        expect(response).to redirect_to(supplier_articles_path(supplier))
        expect(flash[:notice]).to eq I18n.t('articles.controller.update_sync.notice')
      end
    end

    context 'with validation errors' do
      it 'renders the form again with errors' do
        post_with_defaults :update_synchronized, params: {
          supplier_id: supplier.id,
          new_articles: { '0' => { name: '' } }, # Name is required
          from_action: 'sync'
        }

        expect(response).to have_http_status(:ok)
        expect(flash[:alert]).to eq I18n.t('articles.controller.error_invalid')
      end
    end
  end
end
