class ArticleUnitsController < ApplicationController
  before_action :authenticate_article_meta
  before_action :load_available_units, only: %i[search create destroy]

  def index; end

  def search
    @query = article_unit_params[:q].blank? ? nil : article_unit_params[:q].downcase

    existing_article_units = ArticleUnit.all.to_a
    @article_units = @available_units
                     .to_h do |key, value|
      [key, value.merge({ code: key, record: existing_article_units.find do |existing_unit|
                                               existing_unit.unit == key
                                             end })]
    end

    unless @query.nil?
      @article_units = @article_units.select do |_key, value|
        (value[:name].downcase.include?(@query) || value[:symbol]&.downcase&.include?(@query)) &&
          (params[:only_recommended] == '0' || !value[:untranslated])
      end
    end

    @article_units = @article_units
                     .sort { |a, b| sort_by_unit_name(@query, a, b) }
                     .map { |_key, value| value }

    @article_units = @article_units.take(100) unless @query.nil?
    @article_units = @article_units.reject { |unit| unit[:record].nil? } if @query.nil?
  end

  def create
    @article_unit = ArticleUnit.create(unit: params[:unit])
  end

  def destroy
    @article_unit = ArticleUnit.find(params[:id])
    @article_unit.destroy
  end

  private

  def load_available_units
    @available_units = ArticleUnitsLib.units
  end

  def article_unit_params
    params.permit(:q)
  end

  def sort_by_unit_name(query, a_unit, b_unit)
    a_name = a_unit[1][:name].downcase
    b_name = b_unit[1][:name].downcase

    unless query.nil?
      return -1 if a_name.starts_with?(query) && !b_name.starts_with?(query)
      return 1 if !a_name.starts_with?(query) && b_name.starts_with?(query)
    end

    a_name <=> b_name
  end
end
