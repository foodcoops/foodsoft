class Admin::OrdergroupsController < ApplicationController
  before_filter :authenticate_admin
  
  def index
    if (params[:per_page] && params[:per_page].to_i > 0 && params[:per_page].to_i <= 100)
      @per_page = params[:per_page].to_i
    else
      @per_page = 20
    end

    # if the search field is used
    conditions = "name LIKE '%#{params[:query]}%'" unless params[:query].nil?

    @total = Ordergroup.count(:conditions => conditions )
    @ordergroups = Ordergroup.paginate(:conditions => conditions, :page => params[:page],
      :per_page => @per_page, :order => 'name')

    respond_to do |format|
      format.html # index.html.erb
      format.js { render :partial => "ordergroups" }
    end
  end


  def show
    @ordergroup = Ordergroup.find(params[:id])
  end

  def new
    @ordergroup = Ordergroup.new
  end

  def edit
    @ordergroup = Ordergroup.find(params[:id])
  end

  def create
    @ordergroup = Ordergroup.new(params[:ordergroup])

    if @ordergroup.save
      flash[:notice] = 'Ordergroup was successfully created.'
      redirect_to([:admin, @ordergroup])
    else
      render :action => "new"
    end
  end

  def update
    @ordergroup = Ordergroup.find(params[:id])

    if @ordergroup.update_attributes(params[:ordergroup])
      flash[:notice] = 'Ordergroup was successfully updated.'
      redirect_to([:admin, @ordergroup])
    else
      render :action => "edit"
    end
  end

  def destroy
    @ordergroup = Ordergroup.find(params[:id])
    @ordergroup.destroy

    redirect_to(admin_Ordergroups_url)
  end

  def memberships
    @group = Ordergroup.find(params[:id])
  end
end
