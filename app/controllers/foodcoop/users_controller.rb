class Foodcoop::UsersController < ApplicationController

  def index
    # sort by ordergroups
    if params[:sort_by_ordergroups]
      @users = []
      Ordergroup.find(:all, :order => "name").each do |group|
        group.users.each do |user|
          @users << user
        end
      end
      @total = @users.size
    else
    # sort by nick, thats default
      if (params[:per_page] && params[:per_page].to_i > 0 && params[:per_page].to_i <= 100)
        @per_page = params[:per_page].to_i
      else
        @per_page = 20
      end

      # if somebody uses the search field:
      unless params[:query].blank?
        conditions = ["first_name LIKE ? OR last_name LIKE ? OR nick LIKE ?",
          "%#{params[:query]}%", "%#{params[:query]}%", "%#{params[:query]}%"]
      end

      @total = User.count(:conditions => conditions)
      @users = User.paginate(:page => params[:page], :per_page => @per_page, :conditions => conditions, :order => "nick", :include => :groups)

      respond_to do |format|
        format.html # index.html.erb
        format.js { render :partial => "users" }
      end
    end
  end

end
