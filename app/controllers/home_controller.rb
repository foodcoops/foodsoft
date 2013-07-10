# encoding: utf-8
class HomeController < ApplicationController

  def index
    # unaccepted tasks
    @unaccepted_tasks = Task.unaccepted_tasks_for(current_user)
    # task in next week
    @next_tasks = Task.next_assigned_tasks_for(current_user)
    # count tasks with no responsible person
    # tasks for groups the current user is not a member are ignored
    @unassigned_tasks = Task.unassigned_tasks_for(current_user)
  end

  def profile
  end

  def update_profile
    if @current_user.update_attributes(params[:user])
      session[:locale] = @current_user.locale
      redirect_to my_profile_url, notice: I18n.t('home.changes_saved')
    else
      render :profile
    end
  end

  def ordergroup
    @user = @current_user
    @ordergroup = @user.ordergroup

    unless @ordergroup.nil?

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

      @financial_transactions = @ordergroup.financial_transactions.page(params[:page]).per(@per_page).order(sort)
      @financial_transactions = @financial_transactions.where("note LIKE ?", "%#{params[:query]}%") if params[:query].present?

    else
      redirect_to root_path, :alert => I18n.t('home.no_ordergroups')
    end
  end

  # cancel personal memberships direct from the myProfile-page
  def cancel_membership
    membership = Membership.find(params[:membership_id])
    if membership.user == current_user
      membership.destroy
      flash[:notice] = I18n.t('home.ordergroup_cancelled', :group => membership.group.name)
    else
      flash[:error] = I18n.t('errors.general')
    end
    redirect_to my_profile_path
  end

end
