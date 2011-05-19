class ArticlesController < ApplicationController
  before_filter :authenticate_article_meta, :find_supplier

  def index
    if (params[:per_page] && params[:per_page].to_i > 0 && params[:per_page].to_i <= 500)
      @per_page = params[:per_page].to_i
    else
      @per_page = 30
    end

    if params['sort']
    sort = case params['sort']
             when "name"  then "articles.name"
             when "unit"   then "articles.unit"
             when "category" then "article_categories.name"
             when "note"   then "articles.note"
             when "availability" then "articles.availability"
             when "name_reverse"  then "articles.name DESC"
             when "unit_reverse"   then "articles.unit DESC"
             when "category_reverse" then "article_categories.name DESC"
             when "note_reverse" then "articles.note DESC"
             when "availability_reverse" then "articles.availability DESC"
             end
    else
      sort = "article_categories.name, articles.name"
    end

    @articles = @supplier.articles.includes(:article_category).order(sort)
    @articles = @articles.where(:name.matches => "%#{params[:query]}%") unless params[:query].nil?

    @total = @articles.size
    @articles = @articles.paginate(:page => params[:page], :per_page => @per_page)

    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def new
    @article = @supplier.articles.build(:tax => 7.0)
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
    @article.destroy unless @order = @article.in_open_order # If article is in an active Order, the Order will be returned
    render :layout => false
  end   
  
  # Renders a form for editing all articles from a supplier
  def edit_all
    @articles = @supplier.articles
  end

  # Updates all article of specific supplier
  # deletes all articles from params[outlisted_articles]
  def update_all
    currentArticle = nil  # used to find out which article caused a validation exception
    begin
      Article.transaction do
        unless params[:articles].blank?
          # Update other article attributes...
          for id, attributes in params[:articles]
            currentArticle = Article.find(id)
            currentArticle.update_attributes!(attributes)
          end
        end
        # delete articles
        if params[:outlisted_articles]
          params[:outlisted_articles].keys.each {|id| Article.find(id).destroy }
        end
      end
      # Successfully done.
      flash[:notice] = 'Alle Artikel und Preise wurden aktalisiert'
      redirect_to supplier_articles_path(@supplier)

    rescue => e
      # An error has occurred, transaction has been rolled back.
      if currentArticle
        @failedArticle = currentArticle
        flash[:error] = "Es trat ein Fehler beim Aktualisieren des Artikels '#{currentArticle.name}' auf: #{e.message}"
        params[:sync] ? redirect_to(supplier_articles_path(@supplier)) : render(:action => 'edit_all')
      else
        flash[:error] = "Es trat ein Fehler beim Aktualisieren der Artikel auf: #{e.message}"
        redirect_to supplier_articles_path(@supplier)
      end
    end
  end
  
  # makes different actions on selected articles
  def update_selected
    raise 'Du hast keine Artikel ausgewählt' if params[:selected_articles].nil?
    articles = Article.find(params[:selected_articles])

    case params[:selected_action]
    when 'destroy'
      articles.each {|a| a.destroy }
      flash[:notice] = 'Alle gewählten Artikel wurden gelöscht'
    when 'setNotAvailable'
      articles.each {|a| a.update_attribute(:availability, false) }
      flash[:notice] = 'Alle gewählten Artikel wurden auf "nicht verfügbar" gesetzt'
    when 'setAvailable'
      articles.each {|a| a.update_attribute(:availability, true) }
      flash[:notice] = 'Alle gewählten Artikel wurden auf "verfügbar" gesetzt'
    else
      flash[:alert] = 'Keine Aktion ausgewählt!'
    end
    # action succeded
    redirect_to supplier_articles_url(@supplier, :per_page => params[:per_page])
      
  rescue => error
    redirect_to supplier_articles_url(@supplier, :per_page => params[:per_page]),
                :alert => "Ein Fehler ist aufgetreten: #{error}"
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
      articles.each do |row|
        # creates a new article and price
        article = Article.new( :name => row[:name], 
                               :note => row[:note],
                               :manufacturer => row[:manufacturer],
                               :origin => row[:origin],
                               :unit => row[:unit],
                               :article_category => ArticleCategory.find_by_name(row[:category]),
                               :price => row[:price],
                               :unit_quantity => row[:unit_quantity],
                               :order_number => row[:number],
                               :deposit => row[:deposit],
                               :tax => row[:tax])
        # stop parsing, when an article isn't valid
        unless article.valid?
          raise article.errors.full_messages.join(", ") + " ..in line " +  (articles.index(row) + 2).to_s
        end
        @articles << article
      end
      flash.now[:notice] = "#{@articles.size} articles are parsed successfully."
    rescue => error
      redirect_to upload_supplier_articles_path(@supplier), :alert => "An error has occurred: #{error.message}"
    end
  end
 
  # creates articles from form
  def create_from_upload
    begin
      Article.transaction do
        for article_attributes in params[:articles]
          @supplier.articles.create!(article_attributes)
        end
      end
      # Successfully done.
      flash[:notice] = "The articles are saved successfully"
      redirect_to supplier_articles_path(@supplier)
    rescue => error
      # An error has occurred, transaction has been rolled back.
      flash[:error] = "An error occured: #{error.message}"
      redirect_to upload_supplier_articles_path(@supplier)
    end
  end
  
  # renders a view to import articles in local database
  #   
  def shared
    # build array of keywords, required for meta search _all suffix
    params[:search][:name_contains_all] = params[:search][:name_contains_all].split(' ') if params[:search]
    # Build search with meta search plugin
    @search = @supplier.shared_supplier.shared_articles.search(params[:search])
    @articles = @search.paginate :page => params[:page], :per_page => 10
    render :layout => false
  end
  
  # fills a form whith values of the selected shared_article
  def import
    @article = SharedArticle.find(params[:shared_article_id]).build_new_article
    render :action => 'new', :layout => false
  end
  
  # sync all articles with the external database
  # renders a form with articles, which should be updated
  def sync
    # check if there is an shared_supplier
    unless @supplier.shared_supplier
      redirect_to supplier_articles_url(@supplier), :alert => "#{@supplier.name} ist nicht mit einer externen Datenbank verknüpft."
    end
    # sync articles against external database
    @updated_articles, @outlisted_articles = @supplier.sync_all
    # convert to db-compatible-string
    @updated_articles.each {|a, b| a.shared_updated_on = a.shared_updated_on.to_formatted_s(:db)}
    if @updated_articles.empty? && @outlisted_articles.empty?
      redirect_to supplier_articles_path(@supplier), :notice => "Der Katalog ist aktuell."
    end
  end
end