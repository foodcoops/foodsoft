class HomeController < ApplicationController
  def index
    # unaccepted tasks
    @unaccepted_tasks = Task.order(:due_date).unaccepted_tasks_for(current_user)
    # task in next week
    @next_tasks = Task.order(:due_date).next_assigned_tasks_for(current_user)
    # count tasks with no responsible person
    # tasks for groups the current user is not a member are ignored
    @unassigned_tasks = Task.order(:due_date).next_unassigned_tasks_for(current_user)
  end

  def profile
  end

  def reference_calculator
    if current_user.ordergroup
      @types = FinancialTransactionType.with_name_short.order(:name)
      @bank_accounts = @types.includes(:bank_account).map(&:bank_account).uniq.compact
      @bank_accounts = [BankAccount.last] if @bank_accounts.empty?
    else
      redirect_to root_url, alert: I18n.t('group_orders.errors.no_member')
    end
  end

  def update_profile
    if @current_user.update(user_params)
      @current_user.ordergroup.update(ordergroup_params) if ordergroup_params
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

      @ordergroup = Ordergroup.include_transaction_class_sum.find(@ordergroup.id)

      if params['sort']
        sort = case params['sort']
               when "date" then "created_on"
               when "note"   then "note"
               when "amount" then "amount"
               when "date_reverse" then "created_on DESC"
               when "note_reverse" then "note DESC"
               when "amount_reverse" then "amount DESC"
               end
      else
        sort = "created_on DESC"
      end

      @financial_transactions = @ordergroup.financial_transactions.visible.page(params[:page]).per(@per_page).order(sort)
      @financial_transactions = @financial_transactions.where('financial_transactions.note LIKE ?', "%#{params[:query]}%") if params[:query].present?

    else
      redirect_to root_path, alert: I18n.t('home.no_ordergroups')
    end
  end

  # cancel personal memberships direct from the myProfile-page
  def cancel_membership
    if params[:membership_id]
      membership = @current_user.memberships.find(params[:membership_id])
    else
      membership = @current_user.memberships.find_by_group_id!(params[:group_id])
    end
    membership.destroy
    redirect_to my_profile_path, notice: I18n.t('home.ordergroup_cancelled', :group => membership.group.name)
  end

  protected

  def user_params
    params
      .require(:user)
      .permit(:first_name, :last_name, :email, :phone,
              :password, :password_confirmation).merge(params[:user].slice(:settings_attributes))
  end

  def ordergroup_params
    if params[:user][:ordergroup]
      params.require(:user).require(:ordergroup).permit(:contact_address)
    end
  end
end
