class Admin::UsersController < Admin::BaseController
  inherit_resources

  def index
    @users = User.order('nick ASC')

    # if somebody uses the search field:
    unless params[:user_name].blank?
      @users = @users.where("first_name LIKE :user_name OR last_name LIKE :user_name OR nick LIKE :user_name",
                            user_name: "%#{params[:user_name]}%")
    end

    @users = @users.page(params[:page]).per(@per_page)
  end
end
