class ArticlesController < ApplicationController
  before_action :authenticate_article_meta, :find_supplier

  before_action :load_article, only: %i[edit update]
  before_action :load_article_units, only: %i[edit update new create]
  before_action :load_article_categories, only: %i[edit_all copy migrate_units update_all]
  before_action :new_empty_article_ratio,
                only: %i[edit edit_all migrate_units update new create parse_upload sync update_synchronized]

  def index
    sort = if params['sort']
             case params['sort']
             when 'name' then 'article_versions.name'
             when 'unit' then 'article_versions.unit'
             when 'article_category' then 'article_categories.name'
             when 'note' then 'article_versions.note'
             when 'availability' then 'article_versions.availability'
             when 'name_reverse' then 'article_versions.name DESC'
             when 'unit_reverse' then 'article_versions.unit DESC'
             when 'article_category_reverse' then 'article_categories.name DESC'
             when 'note_reverse' then 'article_versions.note DESC'
             when 'availability_reverse' then 'article_versions.availability DESC'
             end
           else
             'article_categories.name, article_versions.name'
           end

    @articles = Article.with_latest_versions_and_categories.order(sort).undeleted.where(supplier_id: @supplier,
                                                                                        type: nil)

    if request.format.csv?
      send_data ArticlesCsv.new(@articles, encoding: 'utf-8').to_csv, filename: 'articles.csv', type: 'text/csv'
      return
    end

    @articles = @articles.where('article_versions.name LIKE ?', "%#{params[:query]}%") unless params[:query].nil?

    @articles = @articles.page(params[:page]).per(@per_page)

    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end

  def new
    @article = @supplier.articles.build
    @article.latest_article_version = @article.article_versions.build(tax: FoodsoftConfig[:tax_default])
    render layout: false
  end

  def copy
    article = @supplier.articles.find(params[:article_id])
    @article = article.duplicate_including_latest_version_and_ratios
    load_article_units(@article.current_article_units)
    render layout: false
  end

  def edit
    render action: 'new', layout: false
  end

  def create
    valid = false
    Article.transaction do
      @article = Article.create(supplier_id: @supplier.id)
      @article.attributes = { latest_article_version_attributes: params[:article_version] }
      raise ActiveRecord::Rollback unless @article.valid?

      valid = @article.save
    end

    if valid
      render layout: false
    else
      load_article_units(@article.current_article_units)
      render action: 'new', layout: false
    end
  end

  # Updates one Article and highlights the line if succeded
  def update
    Article.transaction do
      if @article.update(latest_article_version_attributes: params[:article_version])
        render layout: false
      else
        Rails.logger.info @article.errors.to_yaml.to_s
        render action: 'new', layout: false
      end
    end
  end

  # Deletes article from database. send error msg, if article is used in a current order
  def destroy
    @article = Article.find(params[:id])
    @article.mark_as_deleted unless @order = @article.in_open_order # If article is in an active Order, the Order will be returned
    render layout: false
  end

  # Renders a form for editing all articles from a supplier
  def edit_all
    @articles = @supplier.articles.undeleted

    load_article_units
  end

  def prepare_units_migration; end

  def migrate_units
    build_article_migration_samples
  end

  def complete_units_migration
    @invalid_articles = []
    @samples = []

    Article.transaction do
      params[:samples].values.each do |sample|
        next unless sample[:apply_migration] == '1'

        original_unit = nil
        articles = Article.with_latest_versions_and_categories
                          .includes(latest_article_version: [:article_unit_ratios])
                          .find(sample[:article_ids])
        articles.each do |article|
          latest_article_version = article.latest_article_version
          original_unit = latest_article_version.unit
          next if latest_article_version.article_unit_ratios.length > 1 ||
                  latest_article_version.billing_unit != latest_article_version.group_order_unit ||
                  latest_article_version.price_unit != latest_article_version.group_order_unit

          article_version_params = sample.slice(:supplier_order_unit, :group_order_granularity, :group_order_unit)
          article_version_params[:unit] = nil
          article_version_params[:billing_unit] = article_version_params[:group_order_unit]
          article_version_params[:price_unit] = article_version_params[:group_order_unit]
          article_version_params[:article_unit_ratios_attributes] = {}
          if sample[:first_ratio_unit].present?
            article_version_params[:article_unit_ratios_attributes]['1'] = {
              id: latest_article_version.article_unit_ratios.first&.id,
              sort: 1,
              quantity: sample[:first_ratio_quantity],
              unit: sample[:first_ratio_unit]
            }
          end
          article_version_params[:id] = latest_article_version.id
          @invalid_articles << article unless article.update(latest_article_version_attributes: article_version_params)
        end

        errors = articles.find { |a| !a.errors.nil? }&.errors
        @samples << {
          unit: original_unit,
          conversion_result: sample
                    .except(:article_ids, :first_ratio_quantity, :first_ratio_unit)
                    .merge(
                      first_ratio: {
                        quantity: sample[:first_ratio_quantity],
                        unit: sample[:first_ratio_unit]
                      }
                    ),
          articles: articles,
          errors: errors,
          error: errors.present?
        }
      end
      @supplier.update_attribute(:unit_migration_completed, Time.now)
      raise ActiveRecord::Rollback unless @invalid_articles.empty?
    end

    if @invalid_articles.empty?
      redirect_to supplier_articles_path(@supplier),
                  notice: I18n.t('articles.controller.complete_units_migration.notice')
    else
      additional_units = @samples.map do |sample|
        [sample[:conversion_result][:supplier_order_unit], sample[:conversion_result][:group_order_unit],
         sample[:conversion_result][:first_ratio]&.dig(:unit)]
      end.flatten.uniq.compact
      load_article_units(additional_units)

      flash.now.alert = I18n.t('articles.controller.error_invalid')
      render :migrate_units
    end
  end

  # Updates all article of specific supplier
  def update_all
    invalid_articles = false

    Article.transaction do
      if params[:articles].present?
        # Update other article attributes...
        @articles = Article.with_latest_versions_and_categories
                           .includes(latest_article_version: [:article_unit_ratios])
                           .find(params[:articles].keys)
        @articles.each do |article|
          article_version_params = params[:articles][article.id.to_s]
          article_version_params['id'] = article.latest_article_version.id
          unless article.update(latest_article_version_attributes: article_version_params)
            invalid_articles ||= true # Remember that there are validation errors
          end
        end

        @supplier.update_attribute(:unit_migration_completed, Time.now) if params[:complete_migration]

        raise ActiveRecord::Rollback if invalid_articles # Rollback all changes
      end
    end

    if invalid_articles
      # An error has occurred, transaction has been rolled back.
      flash.now.alert = I18n.t('articles.controller.error_invalid')
      render :edit_all
    else
      # Successfully done.
      redirect_to supplier_articles_path(@supplier), notice: I18n.t('articles.controller.update_all.notice')
    end
  end

  # makes different actions on selected articles
  def update_selected
    raise I18n.t('articles.controller.error_nosel') if params[:selected_articles].nil?

    articles = Article.with_latest_versions_and_categories
                      .includes(latest_article_version: [:article_unit_ratios])
                      .find(params[:selected_articles])
    Article.transaction do
      case params[:selected_action]
      when 'destroy'
        articles.each(&:mark_as_deleted)
        flash[:notice] = I18n.t('articles.controller.update_sel.notice_destroy')
      when 'setNotAvailable'
        articles.each { |a| a.update_attribute(:availability, false) }
        flash[:notice] = I18n.t('articles.controller.update_sel.notice_unavail')
      when 'setAvailable'
        articles.each { |a| a.update_attribute(:availability, true) }
        flash[:notice] = I18n.t('articles.controller.update_sel.notice_avail')
      else
        flash[:alert] = I18n.t('articles.controller.update_sel.notice_noaction')
      end
    end
    # action succeded
    redirect_to supplier_articles_url(@supplier, per_page: params[:per_page])
  rescue StandardError => e
    redirect_to supplier_articles_url(@supplier, per_page: params[:per_page]),
                alert: I18n.t('errors.general_msg', msg: e)
  end

  # lets start with parsing articles from uploaded file, yeah
  # Renders the upload form
  def upload; end

  # Update articles from a spreadsheet
  def parse_upload
    uploaded_file = params[:articles]['file'] or raise I18n.t('articles.controller.parse_upload.no_file')
    options = { filename: uploaded_file.original_filename }
    options[:outlist_absent] = (params[:articles]['outlist_absent'] == '1')
    options[:convert_units] = (params[:articles]['convert_units'] == '1')
    @updated_article_pairs, @outlisted_articles, @new_articles, import_data = @supplier.sync_from_file(uploaded_file.tempfile,
                                                                                                       options)

    @articles = @updated_article_pairs.pluck(0) + @new_articles
    load_article_units

    if @updated_article_pairs.empty? && @outlisted_articles.empty? && @new_articles.empty?
      redirect_to supplier_articles_path(@supplier),
                  notice: I18n.t('articles.controller.parse_upload.notice', count: import_data[:articles].length)
    end
    @ignored_article_count = 0
  rescue StandardError => e
    redirect_to upload_supplier_articles_path(@supplier), alert: I18n.t('errors.general_msg', msg: e.message)
  end

  # sync all articles with the external database
  # renders a form with articles, which should be updated
  def sync
    @updated_article_pairs, @outlisted_articles, @new_articles, import_data = @supplier.sync_from_remote
    redirect_to(supplier_articles_path(@supplier), notice: I18n.t('articles.controller.parse_upload.notice', count: import_data[:articles].length)) if @updated_article_pairs.empty? && @outlisted_articles.empty? && @new_articles.empty?
    @ignored_article_count = 0
    load_article_units((@new_articles + @updated_article_pairs.map(&:first)).map(&:current_article_units).flatten.uniq)
  rescue StandardError => e
    redirect_to upload_supplier_articles_path(@supplier), alert: I18n.t('errors.general_msg', msg: e.message)
  end

  # Updates, deletes articles when upload or sync form is submitted
  def update_synchronized
    @outlisted_articles = Article.includes(:latest_article_version).where(article_versions: { id: params[:outlisted_articles]&.values || [] })
    @updated_articles = Article.includes(:latest_article_version).where(article_versions: { id: params[:articles]&.values&.map do |v|
                                                                                                  v[:id]
                                                                                                end || [] })
    @new_articles = (params[:new_articles]&.values || []).map do |a|
      article = @supplier.articles.build
      article_version = article.article_versions.build(a)
      article.article_versions << article_version
      article.latest_article_version = article_version
      article_version.article = article
      article
    end

    has_error = false
    Article.transaction do
      # delete articles
      begin
        @outlisted_articles.each(&:mark_as_deleted)
      rescue StandardError
        # raises an exception when used in current order
        has_error = true
      end
      # Update articles
      @updated_articles.each_with_index do |a, index|
        current_params = params[:articles][index.to_s]
        current_params.delete(:id)

        a.latest_article_version.article_unit_ratios.clear
        a.latest_article_version.assign_attributes(current_params)
        a.save
      end or has_error = true
      # Add new articles
      @new_articles.each { |a| a.save or has_error = true }

      raise ActiveRecord::Rollback if has_error
    end

    if has_error
      load_article_units((@new_articles + @updated_articles).map(&:current_article_units).flatten.uniq)
      @updated_article_pairs = @updated_articles.map do |article|
        orig_article = Article.find(article.id)
        [article, orig_article.unequal_attributes(article)]
      end
      flash.now.alert = I18n.t('articles.controller.error_invalid')
      render params[:from_action] == 'sync' ? :sync : :parse_upload
    else
      redirect_to supplier_articles_path(@supplier), notice: I18n.t('articles.controller.update_sync.notice')
    end
  end

  private

  def build_article_migration_samples
    articles = @supplier.articles.with_latest_versions_and_categories.undeleted.includes(latest_article_version: [:article_unit_ratios])
    samples_hash = {}
    articles.each do |article|
      article_version = article.latest_article_version
      quantity = 1
      ratios = article_version.article_unit_ratios

      next if ratios.length > 1 ||
              article_version.billing_unit != article_version.group_order_unit ||
              article_version.price_unit != article_version.group_order_unit

      quantity = ratios[0].quantity if ratios.length == 1 && ratios[0].quantity != 1 && ratios[0].unit == 'XPP'

      samples_hash[article_version.unit] = {} if samples_hash[article_version.unit].nil?
      samples_hash[article_version.unit][quantity] = [] if samples_hash[article_version.unit][quantity].nil?
      samples_hash[article_version.unit][quantity] << article
    end
    @samples = samples_hash.map do |unit, quantities_hash|
      quantities_hash.map do |quantity, sample_articles|
        conversion_result = ArticleUnitsLib.convert_old_unit(unit, quantity)
        { unit: unit, quantity: quantity, articles: sample_articles, conversion_result: conversion_result }
      end
    end
    @samples = @samples.flatten
                       .reject { |sample| sample[:conversion_result].nil? }

    additional_units = @samples.map do |sample|
      [sample[:conversion_result][:supplier_order_unit], sample[:conversion_result][:group_order_unit],
       sample[:conversion_result][:first_ratio]&.dig(:unit)]
    end.flatten.uniq.compact
    load_article_units(additional_units)
  end

  def load_article
    @article = Article
               .with_latest_versions_and_categories
               .includes(latest_article_version: [:article_unit_ratios])
               .find(params[:id])
  end

  def load_article_units(additional_units = [])
    additional_units = if !@article.nil?
                         @article.current_article_units
                       elsif !@articles.nil?
                         @articles.map(&:current_article_units)
                                  .flatten
                                  .uniq
                       else
                         additional_units
                       end

    @article_units = ArticleUnit.as_options(additional_units: additional_units)
    @all_units = ArticleUnit.as_hash(additional_units: additional_units)
  end

  def load_article_categories
    @article_categories = ArticleCategory.all
  end

  def new_empty_article_ratio
    @empty_article_unit_ratio = ArticleUnitRatio.new
    @empty_article_unit_ratio.article_version = @article.latest_article_version unless @article.nil?
    @empty_article_unit_ratio.sort = -1
  end

  # @return [Number] Number of articles not taken into account when syncing (having no number)
  def ignored_article_count
    if action_name == 'sync' || params[:from_action] == 'sync'
      @ignored_article_count ||= @supplier.articles.includes(:latest_article_version).undeleted.where(article_versions: { order_number: [
                                                                                                        nil, ''
                                                                                                      ] }).count
    else
      0
    end
  end
  helper_method :ignored_article_count
end
