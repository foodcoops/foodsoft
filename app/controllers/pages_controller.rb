class PagesController < ApplicationController

  def index
    @page = Page.find_by_permalink "Home"

    if @page
      render :action => 'show'
    else
      redirect_to all_pages_path
    end
  end

  def show
    @page = Page.find_by_permalink(params[:permalink])
    
    if @page.nil?
      redirect_to new_page_path(:title => params[:permalink])
    elsif @page.redirect?
      flash[:notice] = "Weitergeleitet von #{@page.title} ..."
      redirect_to wiki_page_path(Page.find(@page.redirect).permalink)
    end
  end

  def new
    @page = Page.new
    @page.title = params[:title].gsub("_", " ") if params[:title]
    @page.parent = Page.find_by_permalink(params[:parent]) if params[:parent]

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @page }
    end
  end

  def edit
    @page = Page.find(params[:id])
  end

  def create
    @page = current_user.pages.build(params[:page])

    if params[:preview]
      render :action => 'new'
    else
      if @page.save
        flash[:notice] = 'Seite wurde angelegt.'
        redirect_to(wiki_page_path(@page.permalink))
      else
        render :action => "new"
      end
    end
  end

  def update
    @page = Page.find(params[:id])
    @page.attributes = params[:page].merge({:user => current_user})

    if params[:preview]
      @page.attributes = params[:page]
      render :action => 'edit'
    else
      if @page.save
        @page.parent_id = parent_id if (!params[:parent_id].blank? \
            and params[:parent_id] != @page_id)
        flash[:notice] = 'Seite wurde aktualisiert.'
        redirect_to wiki_page_path(@page.permalink)
      else
        render :action => "edit"
      end
    end

  rescue ActiveRecord::StaleObjectError
    flash[:error] = "Achtung, die Seite wurde gerade von jemand anderes bearbeitet. Bitte versuche es erneut."
    redirect_to wiki_page_path(@page.permalink)
  end

  def destroy
    @page = Page.find(params[:id])
    @page.destroy

    respond_to do |format|
      format.html { redirect_to(pages_url) }
      format.xml  { head :ok }
    end
  end

  def all
    @pages = Page.all :order => 'updated_at DESC', :conditions => {:redirect => nil}
  end

  def version
    @page = Page.find(params[:id])
    @version = Page::Version.find_by_page_id_and_lock_version params[:id], params[:version]
  end

  def revert
    @page = Page.find(params[:id])
    @page.revert_to!(params[:version].to_i)

    redirect_to wiki_page_path(@page.permalink)
  end
end
