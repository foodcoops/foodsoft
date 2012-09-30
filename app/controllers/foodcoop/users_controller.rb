class Foodcoop::UsersController < ApplicationController

  def index
    @users = User.order('nick ASC')

    # if somebody uses the search field:
    unless params[:query].blank?
      @users = @users.where(({:first_name.matches => "%#{params[:query]}%"}) | ({:last_name.matches => "%#{params[:query]}%"}) | ({:nick.matches => "%#{params[:query]}%"}))
    end

    @users = @users.paginate(:page => params[:page], :per_page => @per_page)

    respond_to do |format|
      format.html # index.html.haml
      format.js { render :layout => false } # index.js.erb
    end
  end

end
