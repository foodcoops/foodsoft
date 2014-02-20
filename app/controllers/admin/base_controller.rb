class Admin::BaseController < ApplicationController
  before_filter :authenticate_admin
  
  def index
    @user = self.current_user
    @groups = Group.where(deleted_at: nil).order('created_on DESC').limit(10)
    @users = User.order('created_on DESC').limit(10)
  end
  
end
