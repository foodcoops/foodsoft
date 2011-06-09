class Admin::UsersController < Admin::BaseController
  inherit_resources

  def index
    @users = User.order(:nick.asc)

    # if somebody uses the search field:
    unless params[:query].blank?
      @users = @users.where(({:first_name.matches => "%#{params[:query]}%"}) | ({:last_name.matches => "%#{params[:query]}%"}) | ({:nick.matches => "%#{params[:query]}%"}))
    end

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

#  def show
#    @user = User.find(params[:id])
#  end
#
#  def new
#    @user = User.new
#  end
#
#  def create
#    @user = User.new(params[:user])
#    if @user.save
#      flash[:notice] = 'Benutzerin wurde erfolgreich angelegt.'
#      redirect_to admin_users_path
#    else
#      render :action => 'new'
#    end
#  end
#
#  def edit
#    @user = User.find(params[:id])
#  end
#
#  def update
#    @user = User.find(params[:id])
#    if @user.update_attributes(params[:user])
#      flash[:notice] = 'Änderungen wurden gespeichert.'
#      redirect_to [:admin, @user]
#    else
#      render :action => 'edit'
#    end
#  end
#
#  def destroy
#    user = User.find(params[:id])
#    if user.nick == @current_user.nick
#      # deny destroying logged-in-user
#      flash[:error] = 'Du darfst Dich nicht selbst löschen.'
#    else
#      user.destroy
#      flash[:notice] = 'Benutzer_in wurde gelöscht.'
#    end
#    redirect_to admin_users_path
#  end

end
