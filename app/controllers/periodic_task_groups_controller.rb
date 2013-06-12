class PeriodicTaskGroupsController < ApplicationController
  def destroy
    @task_group = PeriodicTaskGroup.find(params[:id])
    @task_group.destroy

    redirect_to tasks_url, notice: I18n.t('periodic_task_groups.destroy.notice')
  end
end
