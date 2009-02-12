class AdminController < ApplicationController
  before_filter :authenticate_admin
  filter_parameter_logging :password, :password_confirmation   # do not log passwort parameters

  
  def index
    @user = self.current_user
    @groups = Group.find(:all, :limit => 10, :order => 'created_on DESC', :conditions => {:deleted_at => nil})
    @users = User.find(:all, :limit => 10, :order => 'created_on DESC')
  end
  
end
