class Admin::UsersController < ApplicationController
  before_filter :authenticate_admin

  def index
    if (params[:per_page] && params[:per_page].to_i > 0 && params[:per_page].to_i <= 100)
      @per_page = params[:per_page].to_i
    else
      @per_page = 20
    end
    # if the search field is used
    conditions = "first_name LIKE '%#{params[:query]}%' OR last_name LIKE '%#{params[:query]}%'" unless params[:query].nil?

    @total = User.count(:conditions => conditions)
    @users = User.paginate :page => params[:page], :conditions => conditions, :per_page => @per_page, :order => 'nick'

    respond_to do |format|
      format.html # listUsers.haml
      format.js do
        render :update do |page|
          page.replace_html 'table', :partial => "users"
        end
      end
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = 'Benutzerin wurde erfolgreich angelegt.'
      redirect_to admin_users_path
    else
      render :action => 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = 'Änderungen wurden gespeichert.'
      redirect_to [:admin, @user]
    else
      render :action => 'edit'
    end
  end

  def destroy
    user = User.find(params[:id])
    if user.nick == @current_user.nick
      # deny destroying logged-in-user
      flash[:error] = 'Du darfst Dich nicht selbst löschen.'
    else
      user.destroy
      flash[:notice] = 'Benutzer_in wurde gelöscht.'
    end
    redirect_to admin_users_path
  end

end
