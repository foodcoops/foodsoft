class Admin::UsersController < Admin::BaseController
  inherit_resources

  def index
    @users = params[:show_deleted] ? User.deleted : User.undeleted
    @users = @users.sort_by_param(params["sort"])

    @users = @users.includes(:mail_delivery_status)

    if request.format.csv?
      send_data UsersCsv.new(@users).to_csv, filename: 'users.csv', type: 'text/csv'
    end

    # if somebody uses the search field:
    @users = @users.natural_search(params[:user_name]) unless params[:user_name].blank?

    @users = @users.page(params[:page]).per(@per_page)
  end

  def destroy
    @user = User.find(params[:id])
    @user.mark_as_deleted
    redirect_to admin_users_url, notice: t('admin.users.destroy.notice')
  rescue => error
    redirect_to admin_users_url, alert: t('admin.users.destroy.error', error: error.message)
  end

  def restore
    @user = User.find(params[:id])
    @user.restore
    redirect_to admin_users_url, notice: t('admin.users.restore.notice')
  rescue => error
    redirect_to admin_users_url, alert: t('admin.users.restore.error', error: error.message)
  end

  def sudo
    @user = User.find(params[:id])
    login @user
    redirect_to root_path, notice: I18n.t('admin.users.controller.sudo_done', user: @user.name)
  end
end
