class AdminController < ApplicationController
  before_filter :authenticate_admin
  filter_parameter_logging :password, :password_confirmation   # do not log passwort parameters
  
  verify :method => :post, :only => [ :destroyUser, :createUser, :updateUser, :destroyGroup, :createGroup, :updateGroup], :redirect_to => { :action => :index }

  # Messages
  MSG_USER_CREATED = 'Benutzer_in wurde erfolgreich angelegt.'
  MSG_USER_UPDATED = 'Änderungen wurden gespeichert'
  MSG_USER_DELETED = 'Benutzer_in wurde gelöscht'
  ERR_NO_SELF_DELETE = 'Du darfst Dich nicht selbst löschen'
  MESG_NO_ADMIN_ANYMORE = "Du bist nun kein Admin mehr"
  
  def index
    @user = self.current_user
    @groups = Group.find(:all, :limit => 5, :order => 'created_on DESC')
    @users = User.find(:all, :limit => 5, :order => 'created_on DESC')
  end

# ************************** group actions **************************
  def listGroups
    if (params[:per_page] && params[:per_page].to_i > 0 && params[:per_page].to_i <= 100)
      @per_page = params[:per_page].to_i
    else
      @per_page = 20
    end
    # if the search field is used
    conditions = "name LIKE '%#{params[:query]}%'" unless params[:query].nil?
    
    @total = Group.count(:conditions => conditions)
    @groups = Group.paginate(:conditions => conditions, :page => params[:page], :per_page => @per_page, :order => 'type DESC, name')
    
    respond_to do |format|
      format.html # index.html.erb
      format.js do
        render :update do |page|
          page.replace_html 'table', :partial => "listGroups"
        end
      end
    end
  end

  def showGroup
    @group = Group.find(params[:id])
  end

  def newGroup
      @group = Group.new
      render :action => 'newGroup'
  end

  def newOrderGroup
      @group = OrderGroup.new
      render :action => 'newGroup'
  end
  
  def createGroup
      @group = Group.new(params[:group])
      if @group.save
        flash[:notice] = 'Neue Gruppe wurde angelegt.'
        redirect_to :action => 'members', :id => @group.id
      else
        flash[:error] = 'Gruppe konnte nicht angelegt werden.'
        render :action => 'newGroup'
      end
  end

  def createOrderGroup
      @group = OrderGroup.new(params[:group])
      @group.account_balance = 0
      @group.account_updated = Time.now
      if @group.save
        flash[:notice] = 'Neue Bestellgruppe wurde angelegt.'
        redirect_to :action => 'members', :id => @group.id
      else
        flash[:error] = 'Gruppe konnte nicht angelegt werden.'
        render :action => 'newGroup'
      end
  end

  def editGroup
    @group = Group.find(params[:id])
    render :template => 'groups/edit'
  end
  
  def updateGroup
    @group = Group.find(params[:id])
    if @group.update_attributes(params[:group])
      flash[:notice] = 'Group was successfully updated.'
      redirect_to :action => 'showGroup', :id => @group
    else
      render :template => 'groups/edit'
    end
  end

  def destroyGroup
    begin
      group = Group.find(params[:id])
      group.destroy
      redirect_to :action => 'listGroups'
    rescue => error
      flash[:error] = error.to_s
      redirect_to :action => "showGroup", :id => group
    end
  end

# ************************** Membership methods ******************************

  # loads the membership-page
  def members
    @group = Group.find(params[:id])     
  end
  
  # adds a new member to the group
  def addMember
    @group = Group.find(params[:id])
    user = User.find(params[:user])
    Membership.create(:group => @group, :user => user)
    redirect_to :action => 'memberships_reload', :id => @group
  end
  
  # the membership will find an end....
  def dropMember
    begin
      group = Group.find(params[:group])
      Membership.find(params[:membership]).destroy
      if User.find(@current_user.id).role_admin?
        redirect_to :action => 'memberships_reload', :id => group
      else
        # If the user drops himself from admin group
        flash[:notice] = MESG_NO_ADMIN_ANYMORE
        render(:update) {|page| page.redirect_to :controller => "index"}
      end
    rescue => error
      flash[:error] = error.to_s
      redirect_to :action => 'memberships_reload', :id => group
    end
  end
  
  # the two boxes 'members' and 'non members' will be reload through ajax
  def memberships_reload
    @group = Group.find(params[:id])
    render :update do |page|
      page.replace_html 'members', :partial => 'groups/members',  :object => @group
      page.replace_html 'non_members', :partial => 'groups/non_members', :object => @group
    end
  end


# ****************************** User methdos ******************************
  def listUsers
    if (params[:per_page] && params[:per_page].to_i > 0 && params[:per_page].to_i <= 100)
      @per_page = params[:per_page].to_i
    else
      @per_page = 20
    end
    # if the search field is used
    conditions = "first_name LIKE '%#{params[:query]}%' OR last_name LIKE '%#{params[:query]}%'" unless params[:query].nil?
    
    @total = User.count(:conditions => conditions)
    @users = User.paginate :page => params[:page], :conditions => conditions, :per_page => @per_page, :order => 'nick'
    
    respond_to do |format|
      format.html # listUsers.haml
      format.js do
        render :update do |page|
          page.replace_html 'table', :partial => "listUsers"
        end
      end
    end
  end

  def showUser
    @user = User.find(params[:id])
  end

  def newUser
    @user = User.new
    if request.xml_http_request?
      render :update do |page|
        page.replace_html 'userForm', :partial => "newUser"
        page['newUser'].show
      end
    end 
  end

  def createUser
    @user = User.new(params[:user])
    @user.set_password({:required => true}, params[:user][:password], params[:user][:password_confirmation])
    if @user.errors.empty? && @user.save
      for setting in User::setting_keys.keys 
        @user.settings[setting] = (params[:user][:settings] && params[:user][:settings][setting] == '1' ? '1' : nil)
      end
      flash[:notice] = MSG_USER_CREATED
      redirect_to :action => 'listUsers'
    else
      render :action => 'newUser'
    end   
  end

  def editUser
    @user = User.find(params[:id])
    if request.xml_http_request?
      render :update do |page|
        page.replace_html 'userForm', :partial => "newUser"
        page['newUser'].show
      end
    end
  end

  def updateUser
    @user = User.find(params[:id])
    @user.set_password({:required => false}, params[:user][:password], params[:user][:password_confirmation])
    @user.attributes = params[:user]
    for setting in User::setting_keys.keys 
      @user.settings[setting] = (params[:user][:settings] && params[:user][:settings][setting] == '1' ? '1' : nil)
    end
    if @user.errors.empty? && @user.save
      flash[:notice] = MSG_USER_UPDATED
      redirect_to :action => 'showUser', :id => @user
    else
      render :action => 'editUser'
    end
  end
  

  def destroyUser
    user = User.find(params[:id])
    if user.nick == @current_user.nick
      # deny destroying logged-in-user
      flash[:error] = ERR_NO_SELF_DELETE
    else
      user.destroy
      flash[:notice] = MSG_USER_DELETED
    end
    redirect_to :action => 'listUsers'
  end
  
end
