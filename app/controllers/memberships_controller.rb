class MembershipsController < ApplicationController
    before_filter :authenticate_membership_or_admin

  def add_member
    @group = Group.find(params[:group_id])
    user = User.find(params[:user_id])
    Membership.create(:group => @group, :user => user)
    redirect_to :action => 'reload', :group_id => @group
  end

  def drop_member
    begin
      group = Group.find(params[:group_id])
      Membership.find(params[:membership_id]).destroy
      if User.find(@current_user.id).role_admin?
        redirect_to :action => 'reload', :group_id => group
      else
        # If the user drops himself from admin group
        flash[:notice] = MESG_NO_ADMIN_ANYMORE
        render(:update) {|page| page.redirect_to :controller => "index"}
      end
    rescue => error
      flash[:error] = error.to_s
      redirect_to :action => 'reload', :group_id => group
    end
  end

  def reload
    @group = Group.find(params[:group_id])
    render :update do |page|
      page.replace_html 'members', :partial => 'shared/memberships/current_members',  :object => @group
      page.replace_html 'non_members', :partial => 'shared/memberships/non_members', :object => @group
    end
  end

end
