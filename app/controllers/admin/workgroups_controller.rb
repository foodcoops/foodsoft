class Admin::WorkgroupsController < Admin::BaseController
  
  def index
    if (params[:per_page] && params[:per_page].to_i > 0 && params[:per_page].to_i <= 100)
      @per_page = params[:per_page].to_i
    else
      @per_page = 20
    end

    # if the search field is used
    conditions = "name LIKE '%#{params[:query]}%'" unless params[:query].nil?

    @total = Ordergroup.count(:conditions => conditions )
    @workgroups = Workgroup.paginate(:conditions => conditions, :page => params[:page],
      :per_page => @per_page, :order => 'name')

    respond_to do |format|
      format.html # index.html.erb
      format.js { render :partial => "workgroups" }
    end
  end

  
  def show
    @workgroup = Workgroup.find(params[:id])
  end

  def new
    @workgroup = Workgroup.new
  end

  def edit
    @workgroup = Workgroup.find(params[:id])
  end

  def create
    @workgroup = Workgroup.new(params[:workgroup])

    if @workgroup.save
      flash[:notice] = 'Workgroup was successfully created.'
      redirect_to([:admin, @workgroup])
    else
      render :action => "new"
    end
  end

  def update
    @workgroup = Workgroup.find(params[:id])

    if @workgroup.update_attributes(params[:workgroup])
      flash[:notice] = 'Workgroup was successfully updated.'
      redirect_to([:admin, @workgroup])
    else
      render :action => "edit"
    end
  end

  def destroy
    @workgroup = Workgroup.find(params[:id])
    @workgroup.destroy

    redirect_to(admin_workgroups_url)
  end

  def memberships
    @group = Workgroup.find(params[:id])
  end
end
