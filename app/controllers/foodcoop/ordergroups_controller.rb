class Foodcoop::OrdergroupsController < ApplicationController
  def index
    @ordergroups = Ordergroup.undeleted.sort_by_param(params['sort'])

    @ordergroups = @ordergroups.where('name LIKE ?', "%#{params[:name]}%") if params[:name].present? # Search by name

    @ordergroups = @ordergroups.active if params[:only_active] # Select only active groups

    @ordergroups = @ordergroups.page(params[:page]).per(@per_page)

    respond_to do |format|
      format.html # index.html.erb
      format.js { render layout: false }
    end
  end
end
