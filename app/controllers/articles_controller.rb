# encoding: utf-8
class ArticlesController < ApplicationController
  before_filter :authenticate_article_meta, :find_supplier

  def index
    if params['sort']
      sort = case params['sort']
               when "name"  then "articles.name"
               when "unit"   then "articles.unit"
               when "article_category" then "article_categories.name"
               when "note"   then "articles.note"
               when "availability" then "articles.availability"
               when "name_reverse"  then "articles.name DESC"
               when "unit_reverse"   then "articles.unit DESC"
               when "article_category_reverse" then "article_categories.name DESC"
               when "note_reverse" then "articles.note DESC"
               when "availability_reverse" then "articles.availability DESC"
               end
    else
      sort = "article_categories.name, articles.name"
    end

    @articles = Article.undeleted.where(supplier_id: @supplier, :type => nil).includes(:article_category).order(sort)
    @articles = @articles.where('articles.name LIKE ?', "%#{params[:query]}%") unless params[:query].nil?

    @articles = @articles.page(params[:page]).per(@per_page)

    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def new
    @article = @supplier.articles.build(:tax => FoodsoftConfig[:tax_default])
    render :layout => false
  end

  def create
    @article = Article.new(params[:article])
    if @article.valid? && @article.save
      render :layout => false
    else
      render :action => 'new', :layout => false
    end
  end

  def edit
    @article = Article.find(params[:id])
    render :action => 'new', :layout => false
  end

  # Updates one Article and highlights the line if succeded
  def update
    @article = Article.find(params[:id])

    if @article.update_attributes(params[:article])
      render :layout => false
    else
      render :action => 'new', :layout => false
    end
  end

  # Deletes article from database. send error msg, if article is used in a current order
  def destroy
    @article = Article.find(params[:id])
    @article.mark_as_deleted unless @order = @article.in_open_order # If article is in an active Order, the Order will be returned
    render :layout => false
  end

  # Renders a form for editing all articles from a supplier
  def edit_all
    @articles = @supplier.articles.undeleted
  end

  # Updates all article of specific supplier
  def update_all
    invalid_articles = false

    begin
      Article.transaction do
        unless params[:articles].blank?
          # Update other article attributes...
          @articles = Article.find(params[:articles].keys)
          @articles.each do |article|
            unless article.update_attributes(params[:articles][article.id.to_s])
              invalid_articles = true unless invalid_articles # Remember that there are validation errors
            end
          end

          raise ActiveRecord::Rollback  if invalid_articles # Rollback all changes
        end
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
    articles = Article.find(params[:selected_articles])
    Article.transaction do
      case params[:selected_action]
        when 'destroy'
          articles.each(&:mark_as_deleted)
          flash[:notice] = I18n.t('articles.controller.update_sel.notice_destroy')
        when 'setNotAvailable'
          articles.each {|a| a.update_attribute(:availability, false) }
          flash[:notice] = I18n.t('articles.controller.update_sel.notice_unavail')
        when 'setAvailable'
          articles.each {|a| a.update_attribute(:availability, true) }
          flash[:notice] = I18n.t('articles.controller.update_sel.notice_avail')
        else
          flash[:alert] = I18n.t('articles.controller.update_sel.notice_noaction')
      end
    end
    # action succeded
    redirect_to supplier_articles_url(@supplier, :per_page => params[:per_page])

  rescue => error
    redirect_to supplier_articles_url(@supplier, :per_page => params[:per_page]),
                :alert => I18n.t('errors.general_msg', :msg => error)
  end

  # lets start with parsing articles from uploaded file, yeah
  # Renders the upload form
  def upload
  end

  # Update articles from a spreadsheet
  def parse_upload
    uploaded_file = params[:articles]['file'] or raise I18n.t('articles.controller.parse_upload.no_file')
    options = {filename: uploaded_file.original_filename}
    options[:outlist_absent] = (params[:articles]['outlist_absent'] == '1')
    options[:convert_units] = (params[:articles]['convert_units'] == '1')
    @updated_article_pairs, @outlisted_articles, @new_articles = @supplier.sync_from_file uploaded_file.tempfile, options
    if @updated_article_pairs.empty? && @outlisted_articles.empty? && @new_articles.empty?
      redirect_to supplier_articles_path(@supplier), :notice => I18n.t('articles.controller.parse_upload.notice')
    end
    @ignored_article_count = 0
  rescue => error
    redirect_to upload_supplier_articles_path(@supplier), :alert => I18n.t('errors.general_msg', :msg => error.message)
  end

  # sync all articles with the external database
  # renders a form with articles, which should be updated
  def sync
    # check if there is an shared_supplier
    unless @supplier.shared_supplier
      redirect_to supplier_articles_url(@supplier), :alert => I18n.t('articles.controller.sync.shared_alert', :supplier => @supplier.name)
    end
    # sync articles against external database
    @updated_article_pairs, @outlisted_articles, @new_articles = @supplier.sync_all
    if @updated_article_pairs.empty? && @outlisted_articles.empty? && @new_articles.empty?
      redirect_to supplier_articles_path(@supplier), :notice => I18n.t('articles.controller.sync.notice')
    end
  end

  # Updates, deletes articles when upload or sync form is submitted
  def update_synchronized
    @outlisted_articles = Article.find(params[:outlisted_articles].try(:keys)||[])
    @updated_articles = Article.find(params[:articles].try(:keys)||[])
    @updated_articles.map{|a| a.assign_attributes(params[:articles][a.id.to_s]) }
    @new_articles = (params[:new_articles]||[]).map{|a| @supplier.articles.build(a) }

    has_error = false
    Article.transaction do
      # delete articles
      begin
        @outlisted_articles.each(&:mark_as_deleted)
      rescue
        # raises an exception when used in current order
        has_error = true
      end
      # Update articles
      @updated_articles.map{|a| a.save or has_error=true }
      # Add new articles
      @new_articles.each do |article|
        article.availability = true if @supplier.shared_sync_method == 'all_available'
        article.availability = false if @supplier.shared_sync_method == 'all_unavailable'
        article.save or has_error=true
      end

      raise ActiveRecord::Rollback if has_error
    end

    if !has_error
      redirect_to supplier_articles_path(@supplier), notice: I18n.t('articles.controller.update_sync.notice')
    else
      @updated_article_pairs = @updated_articles.map do |article|
        orig_article = Article.find(article.id)
        [article, orig_article.unequal_attributes(article)]
      end
      flash.now.alert = I18n.t('articles.controller.error_invalid')
      render params[:from_action] == 'sync' ? :sync : :parse_upload
    end
  end

  # renders a view to import articles in local database
  #
  def shared
    # build array of keywords, required for ransack _all suffix
    params[:q][:name_cont_all] = params[:q][:name_cont_all].split(' ') if params[:q]
    # Build search with meta search plugin
    @search = @supplier.shared_supplier.shared_articles.search(params[:q])
    @articles = @search.result.page(params[:page]).per(10)
    render :layout => false
  end

  # fills a form whith values of the selected shared_article
  # when the direct parameter is set and the article is valid, it is imported directly
  def import
    @article = SharedArticle.find(params[:shared_article_id]).build_new_article(@supplier)
    @article.article_category_id = params[:article_category_id] unless params[:article_category_id].blank?
    if params[:direct] && !params[:article_category_id].blank? && @article.valid? && @article.save
      render :action => 'create', :layout => false
    else
      render :action => 'new', :layout => false
    end
  end

  private

  # @return [Number] Number of articles not taken into account when syncing (having no number)
  def ignored_article_count
    if action_name == 'sync' || params[:from_action] == 'sync'
      @ignored_article_count ||= @supplier.articles.undeleted.where(order_number: [nil, '']).count
    else
      0
    end
  end
  helper_method :ignored_article_count
end
