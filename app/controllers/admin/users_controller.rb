class Admin::UsersController < Admin::BaseController
  inherit_resources

  def index
    sort_param_map = {
      "nick" => "nick",
      "nick_reverse" => "nick DESC",
      "name" => "first_name, last_name",
      "email" => "email",
      "last_activity" => "last_activity",
      "name_reverse" => "first_name DESC, last_name DESC",
      "email_reverse" => "email DESC",
      "last_activity_reverse" => "last_activity DESC"
    }

    @users = params[:show_deleted] ? User.deleted : User.undeleted
    @users = @users.order(sort_param_map[params["sort"]] || "first_name, last_name")

    @users = @users.includes(:mail_delivery_status)

    if request.format.csv?
      send_data UsersCsv.new(@users).to_csv, filename: 'users.csv', type: 'text/csv'
    end

    # if somebody uses the search field:
    @users = @users.natural_search(params[:user_name]) unless params[:user_name].blank?

    @users = @users.natural_order.page(params[:page]).per(@per_page)
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
