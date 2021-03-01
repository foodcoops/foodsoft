class MessagegroupsController < ApplicationController
  def index
    @messagegroups = Messagegroup.order("name")
  end

  def join
    @messagegroup = Messagegroup.find(params[:id])
    @messagegroup.users << current_user
    redirect_to messagegroups_url, :notice => I18n.t('messagegroups.join.notice')
  end

  def leave
    @messagegroup = Messagegroup.find(params[:id])
    @messagegroup.users.destroy(current_user)
    redirect_to messagegroups_url, :notice => I18n.t('messagegroups.leave.notice')
  end
end
