class OrdergroupsController < ApplicationController

  # Currently used to display ordergroup name and ids for autocomplete
  def index
    @ordergroups = Ordergroup.undeleted.where('name LIKE ?', "%#{params[:q]}%")
    respond_to do |format|
      format.json { render :json => @ordergroups.map(&:token_attributes).to_json }
    end
  end

end
