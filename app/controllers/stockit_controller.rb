class StockitController < ApplicationController
  before_action :new_empty_article_ratio, only: %i[edit update new create derive copy]
  before_action :load_article,
                only: %i[index_on_stock_article_create index_on_stock_article_update show edit update show_on_stock_article_update
                         destroy]
  before_action :load_article_units, only: %i[edit update new create derive copy]
  before_action :prepare_params_for_create_update, only: %i[create update]

  def index
    @stock_articles = StockArticle.with_latest_versions_and_categories.joins(:supplier).order('suppliers.name, article_categories.name, article_versions.name').undeleted
  end

  def index_on_stock_article_create # See publish/subscribe design pattern in /doc.
    render layout: false
  end

  def index_on_stock_article_update # See publish/subscribe design pattern in /doc.
    render layout: false
  end

  def show
    @stock_changes = @stock_article.stock_changes.order('stock_changes.created_at DESC')
  end

  # three possibilites to fill a new_stock_article form
  # (1) start from blank or use params
  def new
    @stock_article = StockArticle.new(params[:stock_article])
    @stock_article.latest_article_version = ArticleVersion.new

    render layout: false
  end

  # (2) StockArticle as template
  def copy
    stock_article = StockArticle.find(params[:stock_article_id])
    @stock_article = stock_article.dup
    @stock_article.latest_article_version = stock_article.latest_article_version.duplicate_including_article_unit_ratios

    render layout: false
  end

  # (3) non-stock Article as template
  def derive
    article = Article.find(params[:old_article_id])
    @stock_article = article.becomes(StockArticle).dup
    @stock_article.latest_article_version = article.latest_article_version.duplicate_including_article_unit_ratios

    render layout: false
  end

  def edit
    render layout: false
  end

  def create
    StockArticle.transaction do
      @stock_article = StockArticle.create(quantity: 0, supplier_id: @supplier_id)
      @stock_article.attributes = { latest_article_version_attributes: params[:article_version] }
      @stock_article.save
    end
    render layout: false
  rescue ActiveRecord::RecordInvalid
    render action: 'new', layout: false
  end

  def update
    article_version_attributes = params[:article_version]
    @stock_article.update!(supplier_id: @supplier_id,
                                      latest_article_version_attributes: article_version_attributes)
    render layout: false
  rescue ActiveRecord::RecordInvalid
    render action: 'edit', layout: false
  end

  def show_on_stock_article_update # See publish/subscribe design pattern in /doc.
    render layout: false
  end

  def destroy
    @stock_article.mark_as_deleted
    render layout: false
  rescue StandardError => e
    render partial: 'destroy_fail', layout: false,
           locals: { fail_msg: I18n.t('errors.general_msg', msg: e.message) }
  end

  # TODO: Fix this!!
  def articles_search
    @articles = Article.not_in_stock.limit(8).where('name LIKE ?', "%#{params[:term]}%")
    render json: @articles.map(&:name)
  end

  private

  def load_article
    @stock_article = StockArticle.find(params[:id])
  end

  def load_article_units
    additional_units = @stock_article&.current_article_units || []
    @article_units = ArticleUnit.as_options(additional_units: additional_units)
    @all_units = ArticleUnit.as_hash(additional_units: additional_units)
  end

  def new_empty_article_ratio
    @empty_article_unit_ratio = ArticleUnitRatio.new
    @empty_article_unit_ratio.article_version = @article.latest_article_version unless @article.nil?
    @empty_article_unit_ratio.sort = -1
  end

  def prepare_params_for_create_update
    @supplier_id = params[:article_version][:article][:supplier_id]
    params[:article_version].delete :article

    # Stock article form doesn't have some of the unit fields -> set them to supplier_order_unit:
    params[:article_version][:group_order_unit] = params[:article_version][:supplier_order_unit]
    params[:article_version][:billing_unit] = params[:article_version][:supplier_order_unit]
    params[:article_version][:price_unit] = params[:article_version][:supplier_order_unit]
  end
end
