# encoding: utf-8
class VokomokumController < ApplicationController

  skip_before_filter :authenticate, :only => :login

  def login
    raise FoodsoftVokomokum::AuthnException if not request.post? or params[:Mem].blank?

    userinfo = FoodsoftVokomokum.check_user(params[:Mem])
    user = update_or_create_user(userinfo[:id],
                                 userinfo[:email],
                                 userinfo[:first_name],
                                 userinfo[:last_name])
    super user
    redirect_to root_url, notice: "Welkom, Vokomokum lid ##{userinfo[:id]}!"

  rescue FoodsoftVokomokum::AuthnException
    redirect_to FoodsoftConfig[:vokomokum_login_url]
  end


  protected

  def update_or_create_user(id, email, first_name, last_name, workgroups=[])
    User.transaction do
      begin
        user = User.find(id)
      rescue ActiveRecord::RecordNotFound
        user = User.new
        user.id = id
        # no password is used, enter complex random string
        user.password = user.new_random_password(8)
      end
      user.update_attributes email: email, first_name: first_name, last_name: last_name
      user.save!
      # make sure user has an ordergroup (different group id though, since we also have workgroups)
      if user.ordergroup.nil?
        group = Ordergroup.new(name: user.display)
        Membership.new(user: user, group: group).save!
      end
      # TODO update associations to existing workgroups with matching name
      user
    end
  end

end
