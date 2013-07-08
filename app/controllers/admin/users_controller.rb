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

  def create
    # TODO some duplicate code from login_controller#signup
    params[:use_ordergroup] or params[:user].delete(:ordergroup)
    User.transaction do
      @user = User.new(params[:user].reject {|k,v| k=='ordergroup'})
      if params[:user][:ordergroup].nil?
        # create user only
        if @user.save
          redirect_to admin_users_url, notice: I18n.t('admin.users.controller.create.notice_user')
        else
          render :action => 'new'
        end
      else
        # also create ordergroup when fields are present
        @group = Ordergroup.new({
          :name => @user.nick,
          :contact_person => @user.name,
          :contact_phone => @user.phone
        }.merge(params[:user][:ordergroup]))
        if @user.save and @group.save and Membership.new(:user => @user, :group => @group).save!
          redirect_to admin_users_url, notice: I18n.t('admin.users.controller.create.notice_user_group')
        else
          render :action => 'new'
        end
      end
    end
  end
end
