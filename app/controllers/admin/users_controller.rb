class Admin::UsersController < Admin::BaseController
  inherit_resources

  def index
    @users = User.natural_order

    # if somebody uses the search field:
    @users = @users.natural_search(params[:user_name]) unless params[:user_name].blank?

    @users = @users.page(params[:page]).per(@per_page)
  end

  def sudo
    @user = User.find(params[:id])
    login @user
    redirect_to root_path, notice: I18n.t('admin.users.controller.sudo_done', user: @user.name)
  end
end
