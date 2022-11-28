# frozen_string_literal: true

require 'spec_helper'

describe ArticlesController, type: :controller do
  let(:user) { create :user, :role_article_meta }
  let(:article_category_a) { create :article_category, name: "AAAA" }
  let(:article_category_b) { create :article_category, name: "BBBB" }
  let(:article_category_c) { create :article_category, name: "CCCC" }
  let(:supplier) { create :supplier}
  let(:article_a) { create :article, name: 'AAAA', note: "ZZZZ", unit: '750 g', article_category: article_category_b, availability: false, supplier_id: supplier.id }
  let(:article_b) { create :article, name: 'BBBB', note: "XXXX", unit: '500 g', article_category: article_category_a, availability: true, supplier_id: supplier.id }
  let(:article_c) { create :article, name: 'CCCC', note: "YYYY", unit: '250 g', article_category: article_category_c, availability: true, supplier_id: supplier.id  }
  let(:article_no_supplier) { create :article, name: 'no_supplier', note: "no_supplier", unit: '100 g', article_category: article_category_b, availability: true }

  let(:order) { create :order }
  let(:order2) { create :order }

  def get_with_supplier(action, params: {}, xhr: false, format: nil)
    params['supplier_id'] = supplier.id
    get_with_defaults(action, params: params, xhr: xhr, format: format)
  end

  def post_with_supplier(action, params: {}, xhr: false, format: nil)
    params['supplier_id'] = supplier.id
    post_with_defaults(action, params: params, xhr: xhr, format: format)
  end

  before { login user }

  describe 'GET index' do
    before do
      supplier
      article_a
      article_b
      article_c
      supplier.reload
    end
    it 'assigns sorting on articles' do
      sortings = [
        ['name', [article_a, article_b, article_c]],
        ['name_reverse', [article_c, article_b, article_a]],
        ['note', [article_b, article_c, article_a]],
        ['note_reverse', [article_a, article_c, article_b]],
        ['unit', [article_c, article_b, article_a]],
        ['unit_reverse', [article_a, article_b, article_c]],
        ['article_category', [article_b, article_a, article_c]],
        ['article_category_reverse', [article_c, article_a, article_b]],
        ['availability', [article_a, article_b, article_c]],
        ['availability_reverse', [article_b, article_c, article_a]]
      ]
      sortings.each do |sorting|
        get_with_supplier :index, params: { sort: sorting[0] }
        expect(response).to have_http_status(:success)
        expect(assigns(:articles).to_a).to eq(sorting[1])
      end
    end

    it 'triggers an article csv' do
      get_with_supplier :index, format: :csv
      expect(response.header['Content-Type']).to include('text/csv')
      expect(response.body).to include(article_a.unit, article_b.unit)
    end
  end

  describe 'new' do
    it 'renders form for a new article' do
      get_with_supplier :new, xhr: true
      expect(response).to have_http_status(:success)
    end
  end

  describe 'copy' do
    it 'renders form with copy of an article' do
      get_with_supplier :copy, params: { article_id: article_a.id }, xhr: true
      expect(assigns(:article).attributes).to eq(article_a.dup.attributes)
      expect(response).to have_http_status(:success)
    end
  end

  describe '#create' do
    it 'creates a new article' do
      valid_attributes = article_a.attributes.except('id')
      valid_attributes['name'] = 'ABAB'
      get_with_supplier :create, params: { article: valid_attributes }, xhr: true
      expect(response).to have_http_status(:success)
    end

    it 'fails to create a new article and renders #new' do
      get_with_supplier :create, params: { article: { id: nil } }, xhr: true
      expect(response).to have_http_status(:success)
      expect(response).to render_template('articles/new')
    end
  end

  describe 'edit' do
    it 'opens form to edit article attributes' do
      get_with_supplier :edit, params: { id: article_a.id }, xhr: true
      expect(response).to have_http_status(:success)
      expect(response).to render_template('articles/new')
    end
  end

  describe '#edit all' do
    it 'renders edit_all' do
      get_with_supplier :edit_all, xhr: true
      expect(response).to have_http_status(:success)
      expect(response).to render_template('articles/edit_all')
    end
  end

  describe '#update' do
    it 'updates article attributes' do
      get_with_supplier :update, params: { id: article_a.id, article: { unit: '300 g' } }, xhr: true
      expect(assigns(:article).unit).to eq('300 g')
      expect(response).to have_http_status(:success)
    end

    it 'updates article with empty name attribute' do
      get_with_supplier :update, params: { id: article_a.id, article: { name: nil } }, xhr: true
      expect(response).to render_template('articles/new')
    end
  end

  describe '#update_all' do
    it 'updates all articles' do
      get_with_supplier :update_all, params: { articles: { "#{article_a.id}": attributes_for(:article), "#{article_b.id}": attributes_for(:article) } }
      expect(response).to have_http_status(:redirect)
    end

    it 'fails on updating all articles' do
      get_with_supplier :update_all, params: { articles: { "#{article_a.id}": attributes_for(:article, name: 'ab') } }
      expect(response).to have_http_status(:success)
      expect(response).to render_template('articles/edit_all')
    end
  end

  describe '#update_selected' do
    let(:order_article) { create :order_article, order: order, article: article_no_supplier }

    before do
      order_article
    end

    it 'updates selected articles' do
      get_with_supplier :update_selected, params: { selected_articles: [article_a.id, article_b.id] }
      expect(response).to have_http_status(:redirect)
    end

    it 'destroys selected articles' do
      get_with_supplier :update_selected, params: { selected_articles: [article_a.id, article_b.id], selected_action: 'destroy' }
      article_a.reload
      article_b.reload
      expect(article_a).to be_deleted
      expect(article_b).to be_deleted
      expect(response).to have_http_status(:redirect)
    end

    it 'sets availability false on selected articles' do
      get_with_supplier :update_selected, params: { selected_articles: [article_a.id, article_b.id], selected_action: 'setNotAvailable' }
      article_a.reload
      article_b.reload
      expect(article_a).not_to be_availability
      expect(article_b).not_to be_availability
      expect(response).to have_http_status(:redirect)
    end

    it 'sets availability true on selected articles' do
      get_with_supplier :update_selected, params: { selected_articles: [article_a.id, article_b.id], selected_action: 'setAvailable' }
      article_a.reload
      article_b.reload
      expect(article_a).to be_availability
      expect(article_b).to be_availability
      expect(response).to have_http_status(:redirect)
    end

    it 'fails deletion if one article is in open order' do
      get_with_supplier :update_selected, params: { selected_articles: [article_a.id, article_no_supplier.id], selected_action: 'destroy' }
      article_a.reload
      article_no_supplier.reload
      expect(article_a).not_to be_deleted
      expect(article_no_supplier).not_to be_deleted
      expect(response).to have_http_status(:redirect)
    end
  end

  describe '#parse_upload' do
    let(:file) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/files/upload_test.csv'), original_filename: 'upload_test.csv') }

    it 'updates particles from spreadsheet' do
      post_with_supplier :parse_upload, params: { articles: { file: file, outlist_absent: '1', convert_units: '1' } }
      expect(response).to have_http_status(:success)
    end

    it 'missing file not updates particles from spreadsheet' do
      post_with_supplier :parse_upload, params: { articles: { file: nil, outlist_absent: '1', convert_units: '1' } }
      expect(response).to have_http_status(:redirect)
      expect(flash[:alert]).to match(I18n.t('errors.general_msg', msg: "undefined method `original_filename' for \"\":String").to_s)
    end
  end

  describe '#sync' do
    # TODO: double render error in controller
    it 'throws double render error' do
      expect do
        post :sync, params: { foodcoop: FoodsoftConfig[:default_scope], supplier_id: supplier.id }
      end.to raise_error(AbstractController::DoubleRenderError)
    end

    xit 'updates particles from spreadsheet' do
      post :sync, params: { foodcoop: FoodsoftConfig[:default_scope], supplier_id: supplier.id, articles: { '#{article_a.id}': attributes_for(:article), '#{article_b.id}': attributes_for(:article) } }
      expect(response).to have_http_status(:redirect)
    end
  end

  describe '#destroy' do
    let(:order_article) { create :order_article, order: order, article: article_no_supplier }

    before do
      order_article
    end

    it 'does not delete article if order open' do
      get_with_supplier :destroy, params: { id: article_no_supplier.id }, xhr: true
      expect(assigns(:article)).not_to be_deleted
      expect(response).to have_http_status(:success)
      expect(response).to render_template('articles/destroy')
    end

    it 'deletes article if order closed' do
      get_with_supplier :destroy, params: { id: article_b.id }, xhr: true
      expect(assigns(:article)).to be_deleted
      expect(response).to have_http_status(:success)
      expect(response).to render_template('articles/destroy')
    end
  end

  describe '#update_synchronized' do
    let(:order_article) { create :order_article, order: order, article: article_no_supplier }

    before do
      order_article
      article_a
      article_b
      article_no_supplier
    end

    it 'deletes articles' do
      # TODO: double render error in controller
      get_with_supplier :update_synchronized, params: { outlisted_articles: { article_a.id => article_a, article_b.id => article_b } }
      article_a.reload
      article_b.reload
      expect(article_a).to be_deleted
      expect(article_b).to be_deleted
      expect(response).to have_http_status(:redirect)
    end

    it 'updates articles' do
      get_with_supplier :update_synchronized, params: { articles: { article_a.id => { name: 'NewNameA' }, article_b.id => { name: 'NewNameB' } } }
      expect(assigns(:updated_articles).first.name).to eq 'NewNameA'
      expect(response).to have_http_status(:redirect)
    end

    it 'does not update articles if article with same name exists' do
      get_with_supplier :update_synchronized, params: { articles: { article_a.id => { unit: '2000 g' }, article_b.id => { name: 'AAAA' } } }
      error_array = [assigns(:updated_articles).first.errors.first, assigns(:updated_articles).last.errors.first]
      expect(error_array).to include([:name, 'name is already taken'])
      expect(response).to have_http_status(:success)
    end

    it 'does update articles if article with same name was deleted before' do
      get_with_supplier :update_synchronized, params: {
        outlisted_articles: { article_a.id => article_a },
        articles: {
          article_a.id => { name: 'NewName' },
          article_b.id => { name: 'AAAA' }
        }
      }
      error_array = [assigns(:updated_articles).first.errors.first, assigns(:updated_articles).last.errors.first]
      expect(error_array).not_to be_any
      expect(response).to have_http_status(:redirect)
    end

    it 'does not delete articles in open order' do
      get_with_supplier :update_synchronized, params: { outlisted_articles: { article_no_supplier.id => article_no_supplier } }
      article_no_supplier.reload
      expect(article_no_supplier).not_to be_deleted
      expect(response).to have_http_status(:success)
    end

    it 'assigns updated article_pairs on error' do
      get_with_supplier :update_synchronized, params: {
        articles: { article_a.id => { name: 'EEEE' } },
        outlisted_articles: { article_no_supplier.id => article_no_supplier }
      }
      expect(assigns(:updated_article_pairs).first).to eq([article_a, { name: 'EEEE' }])
      article_no_supplier.reload
      expect(article_no_supplier).not_to be_deleted
      expect(response).to have_http_status(:success)
    end

    it 'updates articles in open order' do
      get_with_supplier :update_synchronized, params: { articles: { article_no_supplier.id => { name: 'EEEE' } } }
      article_no_supplier.reload
      expect(article_no_supplier.name).to eq 'EEEE'
      expect(response).to have_http_status(:redirect)
    end
  end

  describe '#shared' do
    let(:shared_supplier) { create :shared_supplier, shared_articles: [shared_article] }
    let(:shared_article) { create :shared_article, name: 'shared' }
    let(:article_s) { create :article, name: 'SSSS', note: 'AAAA', unit: '250 g', article_category: article_category_a, availability: false }

    let(:supplier_with_shared) { create :supplier, shared_supplier: shared_supplier }

    it 'renders view with articles' do
      get_with_defaults :shared, params: { supplier_id: supplier_with_shared.id, name_cont_all_joined: 'shared' }, xhr: true
      expect(assigns(:supplier).shared_supplier.shared_articles).to be_any
      expect(assigns(:articles)).to be_any
      expect(response).to have_http_status(:success)
    end
  end

  describe '#import' do
    let(:shared_supplier) { create :shared_supplier, shared_articles: [shared_article] }
    let(:shared_article) { create :shared_article, name: 'shared' }

    before do
      shared_article
      article_category_a
    end

    it 'fills form with article details' do
      get_with_supplier :import, params: { article_category_id: article_category_b.id, direct: 'true', shared_article_id: shared_article.id }, xhr: true
      expect(assigns(:article)).not_to be_nil
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:create)
    end

    it 'does redirect to :new if param :direct not set' do
      get_with_supplier :import, params: { article_category_id: article_category_b.id, shared_article_id: shared_article.id }, xhr: true
      expect(assigns(:article)).not_to be_nil
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:new)
    end
  end
end
