class StockTakingsController < ApplicationController

  def index
    @stock_takings = StockTaking.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @stock_takings }
    end
  end

  def show
    @stock_taking = StockTaking.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @stock_taking }
    end
  end

  def new
    @stock_taking = StockTaking.new
    StockArticle.without_deleted.each { |a| @stock_taking.stock_changes.build(:stock_article => a) }
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @stock_taking }
    end
  end


  def edit
    @stock_taking = StockTaking.find(params[:id])
  end

  def create
    @stock_taking = StockTaking.new(params[:stock_taking])

    respond_to do |format|
      if @stock_taking.save
        flash[:notice] = 'StockTaking was successfully created.'
        format.html { redirect_to(@stock_taking) }
        format.xml  { render :xml => @stock_taking, :status => :created, :location => @stock_taking }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @stock_taking.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @stock_taking = StockTaking.find(params[:id])

    respond_to do |format|
      if @stock_taking.update_attributes(params[:stock_taking])
        flash[:notice] = 'StockTaking was successfully updated.'
        format.html { redirect_to(@stock_taking) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @stock_taking.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @stock_taking = StockTaking.find(params[:id])
    @stock_taking.destroy

    respond_to do |format|
      format.html { redirect_to(stock_takings_url) }
      format.xml  { head :ok }
    end
  end

  def fill_new_stock_article_form
    article = Article.find(params[:article_id])
    supplier = article.supplier
    stock_article = supplier.stock_articles.build(
      article.attributes.reject { |attr| attr == ('id' || 'type')}
    )

    render :partial => 'stock_article_form', :locals => {:stock_article => stock_article}
  end
  
  def add_stock_article
    article = StockArticle.new(params[:stock_article])
    render :update do |page|
      if article.save
        page.insert_html :top, 'stock_changes', :partial => 'stock_change',
          :locals => {:stock_change => article.stock_changes.build}

        page.replace_html 'new_stock_article', :partial => 'stock_article_form',
          :locals => {:stock_article => StockArticle.new}
      else
        page.replace_html 'new_stock_article', :partial => 'stock_article_form',
          :locals => {:stock_article => article}
      end
    end
  end

  def drop_stock_change
    stock_change = StockChange.find(params[:stock_change_id])
    stock_change.destroy

    render :update do |page|
      page.visual_effect :DropOut, "stock_change_#{stock_change.id}"
    end
  end


end
