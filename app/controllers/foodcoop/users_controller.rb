class Foodcoop::UsersController < ApplicationController

  def index
    @users = User.order(:nick.asc)

    # if somebody uses the search field:
    unless params[:query].blank?
      @users = @users.where(({:first_name.matches => "%#{params[:query]}%"}) | ({:last_name.matches => "%#{params[:query]}%"}) | ({:nick.matches => "%#{params[:query]}%"}))
    end

    # sort by ordergroups
#    if params[:sort_by_ordergroups]
#      @users = @users.joins(:ordergroup).order(:ordergroup => :name.asc) # Retunr dubbled entries, why?
#    end

    # sort by nick, thats default
    if (params[:per_page] && params[:per_page].to_i > 0 && params[:per_page].to_i <= 100)
      @per_page = params[:per_page].to_i
    else
      @per_page = 20
    end

    @users = @users.paginate(:page => params[:page], :per_page => @per_page)

    respond_to do |format|
      format.html # index.html.haml
      format.js { render :layout => false } # index.js.erb
    end
  end

end
