# encoding: utf-8
class TasksController < ApplicationController
  #auto_complete_for :user, :nick
  
  def index
    @non_group_tasks = Task.non_group
    @groups = Workgroup.all
  end
  
  def user
    @unaccepted_tasks = Task.unaccepted_tasks_for(current_user)
    @accepted_tasks = Task.accepted_tasks_for(current_user)
  end
  
  def new
    @task = Task.new(current_user_id: current_user.id)
  end
  
  def create
    @task = Task.new(params[:task])
    if @task.save
      redirect_to tasks_url, :notice => "Aufgabe wurde erstellt"
    else
      render :template => "tasks/new"
    end
  end
  
  def show
    @task = Task.find(params[:id])
  end
  
  def edit
    @task = Task.find(params[:id])
    @task.current_user_id = current_user.id
  end
  
  def update
    @task = Task.find(params[:id])
    @task.attributes=(params[:task])
    if @task.errors.empty?
      @task.save
      flash[:notice] = "Aufgabe wurde aktualisiert"
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
    Task.find(params[:id]).destroy
    redirect_to tasks_url, :notice => "Aufgabe wurde gelöscht"
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
    redirect_to user_tasks_path, :notice => "Du hast die Aufgabe übernommen"
  end
  
  # deletes assignment between current_user and given task
  def reject
    Task.find(params[:id]).users.delete(current_user)
    redirect_to :action => "index"
  end
  
  def set_done
    Task.find(params[:id]).update_attribute :done, true
    redirect_to tasks_url, :notice => "Aufgabenstatus wurde aktualisiert"
  end
  
  # Shows all tasks, which are already done
  def archive
    @tasks = Task.done.page(params[:page]).per(@per_page)
  end
  
  # shows workgroup (normal group) to edit weekly_tasks_template
  def workgroup
    @group = Group.find(params[:workgroup_id])
    if @group.is_a? Ordergroup
      redirect_to tasks_url, :alert => "Keine Arbeitsgruppe gefunden"
    end
  end
end
