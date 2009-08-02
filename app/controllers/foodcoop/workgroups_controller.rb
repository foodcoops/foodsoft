class Foodcoop::WorkgroupsController < ApplicationController

  before_filter :authenticate_membership_or_admin,
    :except => [:index]

  def index
    @workgroups = Workgroup.all :order => "name"
  end
  
  def edit
    @workgroup = Workgroup.find(params[:id])
  end
  
  def update
    @workgroup = Workgroup.find(params[:id])
    if @workgroup.update_attributes(params[:workgroup])
      flash[:notice] = "Arbeitsgruppe wurde aktualisiert"
      redirect_to foodcoop_workgroups_url
    else
      render :action => 'edit'
    end
  end

  def memberships
  end
end
