class FoodcoopController < ApplicationController

  before_filter :authenticate_membership_or_admin, 
    :only => [:edit_group, :update_group, :memberships, :invite, :send_invitation]

  # gives a view to list all members of the foodcoop
  def members

    # sort by ordergroups
    if params[:sort_by_ordergroups]
      @users = []
      Ordergroup.find(:all, :order => "name").each do |group|
        group.users.each do |user|
          @users << user
        end
      end
      @total = @users.size
    else
    # sort by nick, thats default
      if (params[:per_page] && params[:per_page].to_i > 0 && params[:per_page].to_i <= 100)
        @per_page = params[:per_page].to_i
      else
        @per_page = 20
      end

      # if somebody uses the search field:
      conditions = ["first_name LIKE ? OR last_name LIKE ?", "%#{params[:query]}%", "%#{params[:query]}%"] unless params[:query].blank?

      @total = User.count(:conditions => conditions)
      @users = User.paginate(:page => params[:page], :per_page => @per_page, :conditions => conditions, :order => "nick", :include => :groups)

      respond_to do |format|
        format.html # index.html.erb
        format.js { render :partial => "users" }
      end
    end
  end

  # gives an overview for the workgroups and its members
  def workgroups
    @groups = Workgroup.find :all, :order => "name"
  end

  def ordergroups
    #@order_groups = Ordergroup.find :all, :order => "name"
    if (params[:per_page] && params[:per_page].to_i > 0 && params[:per_page].to_i <= 100)
      @per_page = params[:per_page].to_i
    else
      @per_page = 20
    end

    if (params[:only_active].to_i == 1)
      if (! params[:query].blank?)
        conditions = ["orders.starts >= ? AND name LIKE ?", Time.now.months_ago(3), "%#{params[:query]}%"]
      else
        conditions = ["orders.starts >= ?", Time.now.months_ago(3)]
      end
    else
      # if somebody uses the search field:
      conditions = ["name LIKE ?", "%#{params[:query]}%"] unless params[:query].blank?
    end

    @total = Ordergroup.count(:conditions => conditions, :include => "orders")
    @order_groups = Ordergroup.paginate(:page => params[:page], :per_page => @per_page, :conditions => conditions, :order => "name", :include => "orders")

    respond_to do |format|
      format.html # index.html.erb
      format.js { render :partial => "ordergroups" }
    end
  end

  def group
  end

  def edit_group
  end

  def memberships
  end

  # Invites a new user to join foodsoft in this group.
  def invite
    @invite = Invite.new
  end
  
  # Sends an email
  def send_invitation
    @invite = Invite.new(:user => @current_user, :group => @group, :email => params[:invite][:email])
    if @invite.save
      flash[:notice] = format('Es wurde eine Einladung an %s geschickt.', @invite.email)
      redirect_to root_path
    else
      render :action => 'invite'
    end
  end
end
