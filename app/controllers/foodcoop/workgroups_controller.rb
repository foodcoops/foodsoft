class Foodcoop::WorkgroupsController < ApplicationController

  before_filter :authenticate_membership_or_admin,
    :except => [:index]

  def index
    @workgroups = Workgroup.order("name")
  end
  
  def edit
    @workgroup = Workgroup.find(params[:id])
  end
  
  def update
    @workgroup = Workgroup.find(params[:id])
    if @workgroup.update_attributes(params[:workgroup])
      redirect_to foodcoop_workgroups_url, :notice => I18n.t('workgroups.update.notice')
    else
      render :action => 'edit'
    end
  end
end
