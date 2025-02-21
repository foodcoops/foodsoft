class Api::V1::ArticlesController < Api::V1::BaseController
  skip_before_action :authenticate

  def index
    supplier = Supplier.find_by_external_uuid!(index_params.fetch(:shared_supplier_uuid))

    @articles = Article.with_latest_versions_and_categories.undeleted.where(supplier_id: supplier, type: nil)
    @articles = @articles.where('article_versions.updated_at > ?', index_params[:updated_after].to_datetime) if index_params.include?(:updated_after)
    @articles = @articles.where('article_versions.name LIKE ?', "%#{index_params[:name]}%") if index_params.include?(:name)
    @articles = @articles.where(article_versions: { origin: index_params[:origin] }) if index_params.include?(:origin)
    @articles = @articles.page(index_params[:page]).per(index_params.fetch(:per_page)) if index_params.include?(:page)

    data = @articles.map { |article| get_article_version_data(article) }

    render json: { articles: data, pagination: pagination_response, latest_update: get_latest_article_update(supplier) }
  end

  protected

  def index_params
    params.permit(:shared_supplier_uuid, :updated_after, :name, :origin, :page, :per_page)
  end

  def get_article_version_data(article)
    version_attributes = article.latest_article_version.attributes
    version_attributes.delete_if { |key| key == 'id' || key.end_with?('_id') }

    version_attributes['article_unit_ratios'] = article.latest_article_version.article_unit_ratios.map do |ratio|
      ratio_attributes = ratio.attributes
      ratio_attributes.delete_if { |key| key == 'id' || key.end_with?('_id') }
    end

    version_attributes
  end

  def get_latest_article_update(supplier)
    latest_update = Article
                    .with_latest_versions
                    .undeleted
                    .where(supplier_id: supplier, type: nil)
                    .order('article_versions.updated_at DESC')
                    .limit(1)
                    .first&.updated_at
    latest_update&.utc
  end

  def pagination_response
    return nil unless index_params.include?(:page)

    current = @articles.current_page
    total = @articles.total_pages
    {
      current_page: current,
      previous_page: (current > 1 ? (current - 1) : nil),
      next_page: (current == total ? nil : (current + 1)),
      per_page: @articles.limit_value,
      total_pages: total,
      number: @articles.total_count
    }
  end
end
