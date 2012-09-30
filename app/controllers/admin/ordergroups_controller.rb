# encoding: utf-8
class Admin::OrdergroupsController < Admin::BaseController
  inherit_resources
  
  def index
    @ordergroups = Ordergroup.order('name ASC')

    # if somebody uses the search field:
    unless params[:query].blank?
      @ordergroups = @ordergroups.where('name LIKE ?', "%#{params[:query]}%")
    end

    @ordergroups = @ordergroups.paginate(:page => params[:page], :per_page => @per_page)

    respond_to do |format|
      format.html # index.html.haml
      format.js { render :layout => false } # index.js.erb
    end
  end

  def destroy
    @ordergroup = Ordergroup.find(params[:id])
    @ordergroup.destroy
    redirect_to admin_ordergroups_url, :notice => "Bestellgruppe wurde gelöscht"
  rescue => error
    redirect_to admin_ordergroups_url, :alert => "Bestellgruppe konnte nicht gelöscht werden: #{error}"
  end
end
