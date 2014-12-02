# encoding: utf-8
class PagesController < ApplicationController
  before_filter -> { require_plugin_enabled FoodsoftWiki }

  skip_before_filter :authenticate, :only => :all
  before_filter :only => :all do
    authenticate_or_token(['wiki', 'all'])
  end
  before_filter do
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
    @page = Page.new(params[:page].merge({:user => current_user}))

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
    @page.attributes = params[:page].merge({:user => current_user})

    if params[:preview]
      @page.attributes = params[:page]
      render :action => 'edit'
    else
      if @page.save
        @page.parent_id = parent_id if (!params[:parent_id].blank? \
            and params[:parent_id] != @page_id)
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
    @partial = params[:view] || 'recent_changes'

    if params[:name]
      @pages = @pages.where("title LIKE ?", "%#{params[:name]}%").limit(20).order('updated_at DESC')
      @partial = 'title_list'
    else
      order = case @partial
        when 'recent_changes' then
          'updated_at DESC'
        when 'site_map' then
          'created_at DESC'
        when 'title_list' then
          'title DESC'
              end
      @pages.order(order)
    end
    respond_to do |format|
      format.html
      format.rss { render :layout => false }
    end
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
