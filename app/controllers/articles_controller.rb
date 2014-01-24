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
    if @article.valid? and @article.save
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
 
  # parses the articles from a csv and creates a form-table with the parsed data.
  # the csv must have the following format:
  # status | number | name | note | manufacturer | origin | unit | clear price | unit_quantity | tax | deposit | scale quantity | scale price | category
  # the first line will be ignored. 
  # field-seperator: ";"
  # text-seperator: ""
  def parse_upload
    begin
      @articles = Array.new
      articles, outlisted_articles = FoodsoftFile::parse(params[:articles]["file"])
      no_category = ArticleCategory.new
      articles.each do |row|
        # fallback to Others category
        category = (ArticleCategory.find_by_name(row[:category]) or no_category)
        # creates a new article and price
        article = Article.new( :name => row[:name], 
                               :note => row[:note],
                               :manufacturer => row[:manufacturer],
                               :origin => row[:origin],
                               :unit => row[:unit],
                               :article_category => category,
                               :price => row[:price],
                               :unit_quantity => row[:unit_quantity],
                               :order_number => row[:number],
                               :deposit => row[:deposit],
                               :tax => (row[:tax] or FoodsoftConfig[:tax_default]))
        # stop parsing, when an article isn't valid
        unless article.valid?
          raise I18n.t('articles.controller.error_parse', :msg => article.errors.full_messages.join(", "), :line => (articles.index(row) + 2).to_s)
        end
        @articles << article
      end
      flash.now[:notice] = I18n.t('articles.controller.parse_upload.notice', :count => @articles.size)
    rescue => error
      redirect_to upload_supplier_articles_path(@supplier), :alert => I18n.t('errors.general_msg', :msg => error.message)
    end
  end
 
  # creates articles from form
  def create_from_upload
    begin
      Article.transaction do
        invalid_articles = false
        @articles = []
        params[:articles].each do |_key, article_attributes|
          @articles << (article = @supplier.articles.build(article_attributes))
          invalid_articles = true unless article.save
        end

        raise I18n.t('articles.controller.error_invalid') if invalid_articles
      end
      # Successfully done.
      redirect_to supplier_articles_path(@supplier), notice: I18n.t('articles.controller.create_from_upload.notice', :count => @articles.size)

    rescue => error
      # An error has occurred, transaction has been rolled back.
      flash.now[:error] = I18n.t('errors.general_msg', :msg => error.message)
      render :parse_upload
    end
  end
  
  # renders a view to import articles in local database
  #   
  def shared
    # build array of keywords, required for meta search _all suffix
    params[:search][:name_contains_all] = params[:search][:name_contains_all].split(' ') if params[:search]
    # Build search with meta search plugin
    @search = @supplier.shared_supplier.shared_articles.search(params[:search])
    @articles = @search.page(params[:page]).per(10)
    render :layout => false
  end
  
  # fills a form whith values of the selected shared_article
  def import
    @article = SharedArticle.find(params[:shared_article_id]).build_new_article(@supplier)
    render :action => 'new', :layout => false
  end
  
  # sync all articles with the external database
  # renders a form with articles, which should be updated
  def sync
    # check if there is an shared_supplier
    unless @supplier.shared_supplier
      redirect_to supplier_articles_url(@supplier), :alert => I18n.t('articles.controller.sync.shared_alert', :supplier => @supplier.name)
    end
    # sync articles against external database
    @updated_articles, @outlisted_articles = @supplier.sync_all
    # convert to db-compatible-string
    @updated_articles.each {|a, b| a.shared_updated_on = a.shared_updated_on.to_formatted_s(:db)}
    if @updated_articles.empty? && @outlisted_articles.empty?
      redirect_to supplier_articles_path(@supplier), :notice => I18n.t('articles.controller.sync.notice')
    end
    @ignored_article_count = @supplier.articles.where(order_number: [nil, '']).count
  end

  # Updates, deletes articles when sync form is submitted
  def update_synchronized
    begin
      Article.transaction do
        # delete articles
        if params[:outlisted_articles]
          Article.find(params[:outlisted_articles].keys).each(&:mark_as_deleted)
        end

        # Update articles
        params[:articles].each do |id, attrs|
          Article.find(id).update_attributes! attrs
        end
      end

      # Successfully done.
      redirect_to supplier_articles_path(@supplier), notice: I18n.t('articles.controller.update_sync.notice')

    rescue ActiveRecord::RecordInvalid => invalid
      # An error has occurred, transaction has been rolled back.
      redirect_to supplier_articles_path(@supplier),
                  alert: I18n.t('articles.controller.error_update', :article => invalid.record.name, :msg => invalid.record.errors.full_messages)

    rescue => error
      redirect_to supplier_articles_path(@supplier),
                  alert: I18n.t('errors.general_msg', :msg => error.message)
    end
  end
end
