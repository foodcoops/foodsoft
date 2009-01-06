class ArticlesController < ApplicationController
  before_filter :authenticate_article_meta
  verify :method => :post, 
         :only => [ :destroyArticle, :createArticle, :updateArticle, 
                    :update_all, :createArticlesFromFile, :update_selected_articles ], 
         :redirect_to => { :action => :list }

  # messages
  ERROR_NO_SELECTED_ARTICLES = 'Du hast keine Artikel ausgewählt'
  MSG_ALL_CHECKED_DESTROYED = 'Alle gewählten Artikel wurden gelöscht'
  MSG_ALL_CHECKED_UNAVAILABLE = 'Alle gewählten Artikel wurden auf "nicht verfügbar" gesetzt'
  MSG_ALL_CHECKED_AVAILABLE = 'Alle gewählten Artikel wurden auf "verfügbar" gesetzt'
  ERROR_NO_SELECTED_ACTION = 'Keine Aktion ausgewählt!'
  ERROR_UPDATE_ARTICLES = 'Ein Fehler ist aufgetreten: '

  def index
    @suppliers = Supplier.find(:all)
  end

  def list
    if params[:id]
      @supplier = Supplier.find(params[:id])
      @suppliers = Supplier.find(:all)
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
      
      # if somebody uses the search field:
      conditions = ["articles.name LIKE ?", "%#{params[:query]}%"] unless params[:query].nil?
  
      @total = @supplier.articles.count(:conditions => conditions)
      @articles = @supplier.articles.paginate(:order => sort, 
                                               :conditions => conditions,
                                               :page => params[:page],
                                               :per_page => @per_page,
                                               :include => :article_category)
  
      respond_to do |format|
        format.html # list.haml
        format.js do
          render :update do |page|
            page.replace_html 'table', :partial => "list"
          end
        end
      end            
    else
      redirect_to :action => 'index'
    end                             
  end

  def newArticle
    @supplier = Supplier.find(params[:supplier])
    @article = Article.new(:supplier => @supplier, :tax => 7.0)
    render :update do |page|
      page["edit_article"].replace_html :partial => 'new'
      page["edit_article"].show
    end
  end
  
  def createArticle
    @article = Article.new(params[:article])
    if @article.valid? and @article.save
      render :update do |page|
          page.Element.hide('edit_article')
          page.insert_html :top, 'listbody', :partial => 'new_article_row'
          page[@article.id.to_s].visual_effect(:highlight,
                                                :duration => 2)
          # highlights article
          if !@article.availability
            page[@article.id.to_s].addClassName 'unavailable'
          else
            page[@article.id.to_s].addClassName 'just_updated'
          end
      end
    else
      render :update do |page|
        page.replace_html 'edit_article', :partial => "new"
      end
    end    
  end
  
  # edit an article and its price
  def editArticle
    @article = Article.find(params[:id])
    render :update do |page|
      page["edit_article"].replace_html :partial => 'edit'
      page["edit_article"].show
    end
    #render :partial => "quick_edit", :layout => false
  end
  
  # Updates one Article and highlights the line if succeded
  def updateArticle
    @article = Article.find(params[:id])    
    if @article.update_attributes(params[:article])
      render :update do |page|
        page["edit_article"].hide
        page[@article.id.to_s].replace_html :partial => 'article_row'
        
        # hilights an updated article if the article ist available
        page[@article.id.to_s].addClassName 'just_updated' if @article.availability
        
        # highlights an available article and de-highlights in other case 
        if !@article.availability
          page[@article.id.to_s].addClassName 'unavailable'
          # remove updated-class
          page[@article.id.to_s].removeClassName 'just_updated'
        else
          page[@article.id.to_s].removeClassName 'unavailable'
        end
             
        page[@article.id.to_s].visual_effect(:highlight, :delay => 0.5, :duration => 2)
      end
    else
      render :update do |page|
        page["edit_article"].replace_html :partial => "edit"
      end
    end
  end

  # Deletes article from database. send error msg, if article is used in a current order
  def destroyArticle
    @article = Article.find(params[:id])
    @order = @article.inUse #if article is in an active Order, the Order will be returned
    if @order
      render :update do |page|
        page.insert_html :after, @article.id.to_s, :partial => 'destroyActiveArticle'
      end
    else
      @article.destroy
      render :update do |page|
        page[@article.id.to_s].remove
      end
    end
  end   
  
  # Renders a form for editing all articles from a supplier
  def edit_all
    @supplier = Supplier.find(params[:id])
  end
  
  # Updates all article of specific supplier
  # deletes all articles from params[outlisted_articles]
  def update_all
    currentArticle = nil  # used to find out which article caused a validation exception
    begin
      Article.transaction do
        @supplier = Supplier.find(params[:supplier][:id]) if params[:supplier][:id]
        unless params[:article].blank?
          # Update other article attributes...
          i = 0
          for id in params[:article].keys
            currentArticle = Article.find(id)
            currentArticle.update_attributes!(params[:article].values[i])
            i += 1
          end
        end
        # delete articles
        if params[:outlisted_articles]
          params[:outlisted_articles].keys.each {|id| Article.find(id).destroy }
        end
      end  
      # Successfully done.
      flash[:notice] = 'Alle Artikel und Preise wurden aktalisiert'
      redirect_to :action => 'list', :id => @supplier
      
    rescue => e
      # An error has occurred, transaction has been rolled back.
      if currentArticle
        @failedArticle = currentArticle
        flash[:error] = "Es trat ein Fehler beim Aktualisieren des Artikels '#{currentArticle.name}' auf: #{e.message}"
        params[:sync] ? redirect_to(:action => "list", :id => @supplier) : render(:action => 'edit_all')
      else 
        flash[:error] = "Es trat ein Fehler beim Aktualisieren der Artikel auf: #{e.message}"
        redirect_to :action => "index"
      end
    end
  end
  
  # makes different actions on selected articles
  def update_selected_articles
    @supplier = Supplier.find(params[:supplier])
    articles = Array.new
    begin
      raise ERROR_NO_SELECTED_ARTICLES if params[:selected_articles].nil?
      params[:selected_articles].each do |article|
        articles << Article.find(article)  # put selected articles in an array
      end

      case params[:selected_action].to_s
        when 'destroy'
          articles.each {|a| a.destroy }
          flash[:notice] = MSG_ALL_CHECKED_DESTROYED
        when 'setNotAvailable'
          articles.each {|a| a.update_attribute(:availability, false) }
          flash[:notice] = MSG_ALL_CHECKED_UNAVAILABLE
        when 'setAvailable'
          articles.each {|a| a.update_attribute(:availability, true) }
          flash[:notice] = MSG_ALL_CHECKED_AVAILABLE
      else
        flash[:error] = ERROR_NO_SELECTED_ACTION
      end
      # action succeded
      redirect_to :action => 'list', :id => @supplier
      
    rescue => e
      flash[:error] = ERROR_UPDATE_ARTICLES + e
      redirect_to :action => 'list', :id => @supplier
    end
  end
  
  

 #************** start article categories ************************

  def newCategory
    @article_category = ArticleCategory.new
    render :update do |page|
      page['category_form'].replace_html :partial => 'article_categories/new'
      page['category_form'].show
    end
  end

  def createCategory
    @article_category = ArticleCategory.new(params[:article_category])
    if @article_category.save
      render :update do |page|
       page['category_form'].hide
       page['category_list'].replace_html :partial => 'article_categories/list'
       page['category_'+@article_category.id.to_s].visual_effect(:highlight,
                                                                  :duration => 2)
      end
    else
      render :update do |page|
        page['category_form'].replace_html :partial => 'article_categories/new'
      end
    end
  end

  def editCategory
    @article_category = ArticleCategory.find(params[:id])
    render :update do |page|
      page['category_form'].replace_html :partial => 'article_categories/edit'
      page['category_form'].show
    end
  end

  def updateCategory
    @article_category = ArticleCategory.find(params[:id])
    if @article_category.update_attributes(params[:article_category])
      render :update do |page|
       page['category_form'].hide
       page['category_list'].replace_html :partial => 'article_categories/list'
       page['category_'+@article_category.id.to_s].visual_effect(:highlight,
                                                                  :duration => 2)
      end
    else
      render :update do |page|
        page['category_form'].replace_html :partial => 'article_categories/edit'
      end
    end
  end

  def destroyCategory
    @article_category = ArticleCategory.find(params[:id])
    id = @article_category.id.to_s #save the id before destroying the object
    if @article_category.destroy
      render :update do |page|
        page['category_'+id].visual_effect :drop_out
      end
    end
  end
 
  # lets start with parsing articles from uploaded file, yeah
  # Renders the upload form
  def upload_articles
  end
 
  # parses the articles from a csv and creates a form-table with the parsed data.
  # the csv must have the following format:
  # status | number | name | note | manufacturer | origin | unit | clear price | unit_quantity | tax | deposit | scale quantity | scale price | category
  # the first line will be ignored. 
  # field-seperator: ";"
  # text-seperator: ""
  def parse_articles
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
                               :net_price => row[:price],
                               :unit_quantity => row[:unit_quantity],
                               :order_number => row[:number],
                               :deposit => row[:deposit],
                               :tax => row[:tax])
        # stop parsing, when an article isn't valid
        unless article.valid?
          raise article.errors.full_messages.join(", ") + _(" ..in line ") +  (articles.index(row) + 2).to_s
        end
        @articles << article
      end
      flash.now[:notice] = @articles.size.to_s + _(" articles are parsed successfully.")
    rescue => e
      flash[:error] = _("An error has occurred: ") + e.message
      redirect_to :action => 'upload_articles'
    end
  end
 
  # creates articles from form
  def create_articles_from_file
    @supplier = Supplier.find(params[:supplier][:id])
    begin
      Article.transaction do
        i = 0
        params[:article].each do
          @article = Article.new(params[:article][i])
          @article.supplier = @supplier
          @article.save!
          i += 1
        end
      end
      # Successfully done.
      flash[:notice] = _("The articles are saved successfully")
      redirect_to :action => 'list', :id => @supplier
    rescue => e
      # An error has occurred, transaction has been rolled back.
      flash[:error] = _("An error occured: ") + " #{e.message}"
      redirect_to :action => 'upload_articles'
    end
  end
  
  # renders a view to import articles in local database
  #   
  def list_shared_articles
    @supplier = Supplier.find(params[:id])    
    conditions = []
    conditions << "supplier_id = #{@supplier.shared_supplier.id}"
    # check for keywords
    conditions << params[:import_query].split(' ').collect { |keyword| "name LIKE '%#{keyword}%'" }.join(' AND ') unless params[:import_query].blank?
    # check for selected lists
    conditions << "(" + params[:lists].collect {|list| "list = '#{list[0]}'"}.join(" OR ") + ")" if params[:lists]
    # check for regional articles
    conditions << "origin = 'REG'" if params[:regional]
      
    @articles = SharedArticle.paginate :page => params[:page], :per_page => 10, :conditions => conditions.join(" AND ")
    render :update do |page|
      page.replace_html 'search_results', :partial => "import_search_results"
    end  
  end
  
  # fills a form whith values of the selected shared_article
  def new_import
    shared_article = SharedArticle.find(params[:id])
    @article = Article.new(
        :supplier_id => params[:supplier_id],
        :name => shared_article.name,
        :unit => shared_article.unit,
        :note => shared_article.note,
        :manufacturer => shared_article.manufacturer,
        :origin => shared_article.origin,
        :net_price => shared_article.price,
        :tax => shared_article.tax,
        :deposit => shared_article.deposit,
        :unit_quantity => shared_article.unit_quantity,
        :order_number => shared_article.number,
          # convert to db-compatible-string
        :shared_updated_on => shared_article.updated_on.to_formatted_s(:db))
        
    render :update do |page|
      page["edit_article"].replace_html :partial => 'new'
      page["edit_article"].show
    end
  end
  
  # sync all articles with the external database
  # renders a form with articles, which should be updated
  def sync_articles
    @supplier = Supplier.find(params[:id])
    # check if there is an shared_supplier
    unless @supplier.shared_supplier
      flash[:error]= @supplier.name + _(" ist not assigned to an external database.")
      redirect_to :action => "list", :id => @supplier
    end
    # sync articles against external database
    @updated_articles, @outlisted_articles = @supplier.sync_all
      # convert to db-compatible-string
    @updated_articles.each {|a, b| a.shared_updated_on = a.shared_updated_on.to_formatted_s(:db)}
    if @updated_articles.empty? && @outlisted_articles.empty?
      flash[:notice] = _("The database is up to date.")
      redirect_to :action => 'list', :id => @supplier
    end
  end
end