# encoding: utf-8
class TasksController < ApplicationController
  #auto_complete_for :user, :nick

  def index
    @non_group_tasks = Task.non_group.order('due_date', 'name').includes(assignments: :user)
    @groups = Workgroup.order(:name).includes(open_tasks: {assignments: :user})
  end

  def user
    @unaccepted_tasks = Task.unaccepted_tasks_for(current_user)
    @accepted_tasks = Task.accepted_tasks_for(current_user)
  end

  def new
    @task = Task.new(current_user_id: current_user.id)
  end

  def create
    @task = Task.new(current_user_id: current_user.id)
    @task.attributes=(task_params)
    if params[:periodic]
      @task.periodic_task_group = PeriodicTaskGroup.new
    end
    if @task.save
      @task.periodic_task_group.create_tasks_for_upfront_days if params[:periodic]
      redirect_to tasks_url, :notice => I18n.t('tasks.create.notice')
    else
      render :template => "tasks/new"
    end
  end

  def show
    @task = Task.find(params[:id])
  end

  def edit
    @task = Task.find(params[:id])
    @periodic = !!params[:periodic]
    @task.current_user_id = current_user.id
  end

  def update
    @task = Task.find(params[:id])
    task_group = @task.periodic_task_group
    was_periodic = @task.periodic?
    prev_due_date = @task.due_date
    @task.current_user_id = current_user.id
    @task.attributes=(task_params)
    if @task.errors.empty? && @task.save
      task_group.update_tasks_including(@task, prev_due_date) if params[:periodic]
      flash[:notice] = I18n.t('tasks.update.notice')
      if was_periodic && !@task.periodic?
        flash[:notice] = I18n.t('tasks.update.notice_converted')
      end
      if @task.workgroup
        redirect_to workgroup_tasks_url(workgroup_id: @task.workgroup_id)
      else
        redirect_to tasks_url
      end
    else
      render :template => "tasks/edit"
    end
  end

  def destroy
    task = Task.find(params[:id])
    # Save user_ids to update apple statistics after destroy
    user_ids = task.user_ids
    if params[:periodic]
      task.periodic_task_group.exclude_tasks_before(task)
      task.periodic_task_group.destroy
    else
      task.destroy
    end
    task.update_ordergroup_stats(user_ids)

    redirect_to tasks_url, :notice => I18n.t('tasks.destroy.notice')
  end

  # assign current_user to the task and set the assignment to "accepted"
  # if there is already an assignment, only accepted will be set to true
  def accept
    task = Task.find(params[:id])
    if ass = task.is_assigned?(current_user)
      ass.update_attribute(:accepted, true)
    else
      task.assignments.create(:user => current_user, :accepted => true)
    end
    redirect_to user_tasks_path, :notice => I18n.t('tasks.accept.notice')
  end

  # deletes assignment between current_user and given taskcurrent_user_id: current_user.id
  def reject
    Task.find(params[:id]).users.delete(current_user)
    redirect_to :action => "index"
  end

  def set_done
    Task.find(params[:id]).update_attribute :done, true
    redirect_to tasks_url, :notice => I18n.t('tasks.set_done.notice')
  end

  # Shows all tasks, which are already done
  def archive
    @tasks = Task.done.page(params[:page]).per(@per_page).order('tasks.updated_on DESC').includes(assignments: :user)
  end

  # shows workgroup (normal group) to edit weekly_tasks_template
  def workgroup
    @group = Group.find(params[:workgroup_id])
    if @group.is_a? Ordergroup
      redirect_to tasks_url, :alert => I18n.t('tasks.error_not_found')
    end
  end

  private

  def task_params
    params
      .require(:task)
      .permit(:name, :description, :duration, :user_list, :required_users, :workgroup_id, :due_date, :done)
  end

end
