class Admin::UsersController < Admin::BaseController
  inherit_resources

  def index
    @users = User.natural_order

    # if somebody uses the search field:
    @users = @users.natural_search(params[:user_name]) unless params[:user_name].blank?

    @users = @users.page(params[:page]).per(@per_page)
  end
end
