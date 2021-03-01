class PagesController < ApplicationController
  before_action -> { require_plugin_enabled FoodsoftWiki }
  before_action :catch_special_pages, only: [:show, :new]

  skip_before_action :authenticate, :only => :all
  before_action :only => :all do
    authenticate_or_token(['wiki', 'all'])
  end
  before_action do
    content_for :head, view_context.rss_meta_tag
  end

  def index
    @page = Page.find_by_permalink "Home"

    if @page
      render :action => 'show'
    else
      redirect_to all_pages_path
    end
  end

  def show
    if params[:permalink]
      @page = Page.find_by_permalink(params[:permalink])
    elsif params[:id]
      page = Page.find_by_id(params[:id])
      if page.nil?
        flash[:error] = I18n.t('pages.cshow.error_noexist')
        redirect_to all_pages_path and return
      else
        redirect_to wiki_page_path(page.permalink) and return
      end
    end

    if @page.nil?
      redirect_to new_page_path(:title => params[:permalink])
    elsif @page.redirect?
      page = Page.find_by_id(@page.redirect)
      unless page.nil?
        flash[:notice] = I18n.t('pages.cshow.redirect_notice', :page => @page.title)
        redirect_to wiki_page_path(page.permalink)
      end
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
    @page = Page.new(params[:page].merge({ :user => current_user }))

    if params[:preview]
      render :action => 'new'
    else
      if @page.save
        flash[:notice] = I18n.t('pages.create.notice')
        redirect_to(wiki_page_path(@page.permalink))
      else
        render :action => "new"
      end
    end
  end

  def update
    @page = Page.find(params[:id])
    @page.attributes = params[:page].merge({ :user => current_user })

    if params[:preview]
      @page.attributes = params[:page]
      render :action => 'edit'
    else
      if @page.save
        @page.parent_id = parent_id if (!params[:parent_id].blank? \
            && params[:parent_id] != @page_id)
        flash[:notice] = I18n.t('pages.update.notice')
        redirect_to wiki_page_path(@page.permalink)
      else
        render :action => "edit"
      end
    end
  rescue ActiveRecord::StaleObjectError
    flash[:error] = I18n.t('pages.error_stale_object')
    redirect_to wiki_page_path(@page.permalink)
  end

  def destroy
    @page = Page.find(params[:id])
    @page.destroy

    flash[:notice] = I18n.t('pages.destroy.notice', :page => @page.title)
    redirect_to wiki_path
  end

  def all
    @pages = Page.non_redirected
    @partial = params[:view] || 'site_map'

    if params[:name]
      @pages = @pages.where("title LIKE ?", "%#{params[:name]}%").limit(20)
      @partial = 'title_list'
    end
    if params[:sort]
      sort = case params[:sort]
             when "title"                then "title"
             when "title_reverse"        then "title DESC"
             when "last_updated"         then "updated_at DESC"
             when "last_updated_reverse" then "updated_at"
             end
    else
      sort = "title"
    end
    @pages = @pages.order(sort)
    respond_to do |format|
      format.html
      format.rss { render :layout => false }
    end
  end

  def diff
    @page = Page.find(params[:id])
    @old_version = Page::Version.find_by_page_id_and_lock_version params[:id], params[:old]
    @new_version = Page::Version.find_by_page_id_and_lock_version params[:id], params[:new]
    @diff = Diffy::Diff.new(@old_version.body, @new_version.body).to_s(:html)
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

  def variables
    keys = Foodsoft::ExpansionVariables.variables.keys
    @variables = Hash[keys.map { |k| [k, Foodsoft::ExpansionVariables.get(k)] }]
    render 'variables'
  end

  private

  def catch_special_pages
    if params[:id] == 'Help:Foodsoft_variables'
      variables
    end
  end
end
