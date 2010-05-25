class Admin::BaseController < ApplicationController
  before_filter :authenticate_admin
  
  def index
    @user = self.current_user
    @groups = Group.find(:all, :limit => 10, :order => 'created_on DESC', :conditions => {:deleted_at => nil})
    @users = User.find(:all, :limit => 10, :order => 'created_on DESC')
  end
  
end
