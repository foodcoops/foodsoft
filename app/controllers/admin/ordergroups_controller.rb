# encoding: utf-8
class Admin::OrdergroupsController < Admin::BaseController
  inherit_resources
  
  def index
    @ordergroups = Ordergroup.undeleted.order('name ASC')

    # if somebody uses the search field:
    unless params[:query].blank?
      @ordergroups = @ordergroups.where('name LIKE ?', "%#{params[:query]}%")
    end

    @ordergroups = @ordergroups.page(params[:page]).per(@per_page)
  end

  def destroy
    @ordergroup = Ordergroup.find(params[:id])
    @ordergroup.mark_as_deleted
    redirect_to admin_ordergroups_url, :notice => "Bestellgruppe wurde gelöscht"
  rescue => error
    redirect_to admin_ordergroups_url, :alert => "Bestellgruppe konnte nicht gelöscht werden: #{error}"
  end
end
