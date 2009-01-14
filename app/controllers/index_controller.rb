class IndexController < ApplicationController
  # Messages
  MSG_USER_UPDATED = 'Benutzeränderungen wurden gespeichert'
  ERROR_NO_GROUP_MEMBER = 'Du bist kein Gruppenmitglied.'
  MSG_GROUP_UPDATED = 'Gruppe wurde erfolgreich bearbeitet'
  ERR_LAST_MEMBER = "Eine Benutzerin muss der Bestellgruppe erhalten bleiben"
  MSG_MEMBERSHIP_ENDS = 'Du bist nun nicht mehr Mitglied der Gruppe '
  ERR_CANNOT_INVITE = 'Du kannst niemanden in diese Gruppe einladen.'
  MSG_INVITE_SUCCESS = 'Es wurde eine Einladung an %s geschickt.'
  
  def index
    @currentOrders = Order.find_current  
    @orderGroup = @current_user.find_ordergroup
    if @orderGroup
      @financial_transactions = @orderGroup.financial_transactions.find(:all, :order => 'created_on desc', :limit => 3)
    end
    # unread messages
    @messages = Message.find_all_by_recipient_id_and_read(@current_user.id, false, :order => 'messages.created_on desc', :include => :sender)
    # unaccepted tasks
    @unaccepted_tasks = @current_user.unaccepted_tasks
    # task in next week
    @next_tasks = @current_user.next_tasks
    
    # count tasks with no responsible person
    # tasks for groups the current user is not a member are ignored
    tasks = Task.find(:all, :conditions => ["assigned = ? and done = ?", false, false])
    @unassigned_tasks_number = 0
    for task in tasks
      (@unassigned_tasks_number += 1) unless task.group && !current_user.is_member_of(task.group)
    end    
  end
  
  def myProfile
    @user = @current_user
    @user_columns = ["first_name", "last_name", "email", "phone", "address"]
  end
  
  def editProfile
    @user = @current_user
  end
  
  def updateProfile
    @user = @current_user
    @user.set_password({:required => false}, params[:user][:password], params[:user][:password_confirmation])
    @user.attributes = params[:user]
    for setting in User::setting_keys.keys 
      @user.settings[setting] = (params[:user][:settings] && params[:user][:settings][setting] == '1' ? '1' : nil)
    end
    if @user.errors.empty? && @user.save
      flash[:notice] = MSG_USER_UPDATED
      redirect_to :action => 'myProfile'
    else
      render :action => 'editProfile'
    end
  end
  
  def myOrdergroup
    @user = @current_user
    @ordergroup = @user.find_ordergroup
    @ordergroup_column_names = ["Description", "Actual Size", "Balance", "Updated"]
    @ordergroup_columns = ["description", "actual_size", "account_balance", "account_updated"]
                                                          
    #listing the financial transactions with ajax...

    if params['sort']
      sort = case params['sort']
               when "date"  then "created_on"
               when "note"   then "note"
               when "amount" then "amount"
               when "date_reverse"  then "created_on DESC"
               when "note_reverse" then "note DESC"
               when "amount_reverse" then "amount DESC"
               end
      else
        sort = "created_on DESC"
      end
    
    # or if somebody uses the search field:
    conditions = ["note LIKE ?", "%#{params[:query]}%"] unless params[:query].nil?

    @total = @ordergroup.financial_transactions.count(:conditions => conditions)
    @financial_transactions = @ordergroup.financial_transactions.paginate(:page => params[:page],
                                                                    :per_page => 10,
                                                                    :conditions => conditions,
                                                                    :order => sort)
    respond_to do |format|
      format.html # myOrdergroup.haml
      format.js do
        render :update do |page|
          page.replace_html 'table', :partial => "financial_transactions/list"
        end
      end
    end                                                    
  end
  
  def showGroup
    @user = @current_user
    @group = Group.find(params[:id])
  end
  
  def showUser
    @user = User.find(params[:id])
  end
  
  def editGroup
    @group = Group.find(params[:id])
    authenticate_membership(@group)
#    unless @group.member?(@current_user)
#      flash[:error] = ERROR_NO_GROUP_MEMBER
#      redirect_to :action => 'index'
#    end
  end
  
  # update the Group
  # only access to description for Ordergroups
  def updateGroup
    @group = Group.find(params[:id])
    authenticate_membership(@group)
    if @group.is_a?(Ordergroup)
      @group.update_attribute(:description, params[:group][:description])
    else
      @group.update_attributes(params[:group])
    end
    if @group.errors.empty?
      flash[:notice] = MSG_GROUP_UPDATED
      redirect_to :action => 'showGroup', :id => @group
    else
      render :action => 'editGroup'
    end
  end
  
  def members
    @group = Group.find(params[:id])
    authenticate_membership(@group)
  end
  
  # adds a new member to the group
  def addMember
    @group = Group.find(params[:id])
    authenticate_membership(@group)
    user = User.find(params[:user])
    Membership.create(:group => @group, :user => user)
    redirect_to :action => 'memberships_reload', :id => @group
  end
  
  # the membership will find an end....
  def dropMember
    begin
      group = Group.find(params[:group])
      authenticate_membership(group)
      membership = Membership.find(params[:membership])
      if group.is_a?(Ordergroup) && group.memberships.size == 1
        # Deny dropping member if the group is an Ordergroup and there is only one member left.
        flash[:error] = ERR_LAST_MEMBER
      else
        membership.destroy
      end
      redirect_to :action => 'memberships_reload', :id => group
    rescue => error
      flash[:error] = error.to_s
      redirect_to :action => 'memberships_reload', :id => group
    end
  end
  
  # the two boxes 'members' and 'non members' will be reload through ajax
  def memberships_reload
    @group = Group.find(params[:id])
    unless @group.member?(@current_user)
      flash[:error] = ERROR_NO_GROUP_MEMBER
      render(:update) {|page| page.redirect_to :action => "myProfile"}
    else
      render :update do |page|
      page.replace_html 'members', :partial => 'groups/members',  :object => @group
      page.replace_html 'non_members', :partial => 'groups/non_members', :object => @group
      end
    end
  end
  
  # checks if the current_user is member of given group.
  # if fails the user will redirected to startpage
  # method used while group/memberships beeing edit
  def authenticate_membership(group)
    unless group.member?(@current_user)
      flash[:error] = ERROR_NO_GROUP_MEMBER
      if request.xml_http_request?
        render(:update) {|page| page.redirect_to :action => "index"}
      else
        redirect_to :action => 'index'
      end
    end
  end
  
  # gives a view to list all members of the foodcoop
  def foodcoop_members
    
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
      conditions = "first_name LIKE '%#{params[:query]}%' OR last_name LIKE '%#{params[:query]}%'" unless params[:query].blank?
  
      @total = User.count(:conditions => conditions)
      @users = User.paginate(:page => params[:page], :per_page => @per_page, :conditions => conditions, :order => "nick", :include => "groups")
      
      respond_to do |format|
        format.html # index.html.erb
        format.js do
          render :update do |page|
            page.replace_html 'user_table', :partial => "list_members"
          end
        end
      end                                  
    end
  end
  
  # gives an overview for the workgroups and its members
  def workgroups
    @groups = Group.find :all, :conditions => "type != 'Ordergroup'", :order => "name"
  end
  
  # Invites a new user to join foodsoft in this group.
  def invite
    @group = Group.find(params[:id])
    if (!@group || (!@current_user.is_member_of(@group) && !@current_user.role_admin?))
      flash[:error] = ERR_CANNOT_INVITE 
      redirect_to(:action => "index")
    elsif (request.post?)
      @invite = Invite.new(:user => @current_user, :group => @group, :email => params[:invite][:email])
      if @invite.save
        flash[:notice] = format(MSG_INVITE_SUCCESS, @invite.email)
        redirect_to(:action => 'index')
      end
    end
  end
  
  # cancel personal memberships direct from the myProfile-page
  def cancel_membership
    membership = Membership.find(params[:id])
    if membership.user == current_user
      membership.destroy
      flash[:notice] = _("The membership was cancelled.")
    else
      flash[:error] = _("You are not allowed to cancel this membership")
    end
    redirect_to my_profile_path
  end
end
