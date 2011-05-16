class HomeController < ApplicationController
  helper :messages
  
  def index
    # unaccepted tasks
    @unaccepted_tasks = @current_user.unaccepted_tasks
    # task in next week
    @next_tasks = @current_user.next_tasks
    # count tasks with no responsible person
    # tasks for groups the current user is not a member are ignored
    tasks = Task.find(:all, :conditions => ["assigned = ? and done = ?", false, false])
    @unassigned_tasks_number = 0
    for task in tasks
      (@unassigned_tasks_number += 1) unless task.workgroup && !current_user.member_of?(task.workgroup)
    end
  end

  def profile
    @user = @current_user
  end

  def update_profile
    @user = @current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = 'Änderungen wurden gespeichert.'
      redirect_to :action => 'profile'
    else
      render :action => 'profile'
    end
  end

  def ordergroup
    @user = @current_user
    @ordergroup = @user.ordergroup

    unless @ordergroup.nil?
      @ordergroup_column_names = ["Description", "Actual Size", "Balance", "Updated"]
      @ordergroup_columns = ["description", "account_balance", "account_updated"]

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
        format.js { render :layout => false }
      end
    else
      redirect_to root_path, :alert => "Leider bist Du kein Mitglied einer Bestellgruppe"
    end
  end

  # cancel personal memberships direct from the myProfile-page
  def cancel_membership
    membership = Membership.find(params[:membership_id])
    if membership.user == current_user
      membership.destroy
      flash[:notice] = "Du bist jetzt kein Mitglied der Gruppe #{membership.group.name} mehr."
    else
      flash[:error] = "Ein Problem ist aufgetreten."
    end
    redirect_to my_profile_path
  end

end
