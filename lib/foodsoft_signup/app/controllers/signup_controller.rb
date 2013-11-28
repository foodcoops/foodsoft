# encoding: utf-8
class SignupController < ApplicationController
  layout 'login'
  skip_before_filter :authenticate # no authentication since this is the signup page

  # For anyone
  def signup
    if not FoodsoftConfig[:signup]
      redirect_to root_url, alert: I18n.t('signup.controller.disabled', foodcoop: FoodsoftConfig[:name])
    end
    if request.post?
      User.transaction do
        @user = User.new(params[:user].reject {|k,v| k=='ordergroup'})
        @group = Ordergroup.new({
          :name => @user.nick,
          :contact_person => @user.name,
          :contact_phone => @user.phone
        }.merge((params[:user][:ordergroup] or {})))
        if @user.save and @group.save
          Membership.new(:user => @user, :group => @group).save!
          login @user
          url = if !FoodsoftConfig[:membership_fee].nil? and FoodsoftConfig[:ordergroup_approval_payment]
            FoodsoftSignup.payment_link self
          else
            root_url
          end
          redirect_to url, notice: I18n.t('signup.controller.notice')
        end
      end
    else
      @user = User.new
      @user.settings.defaults['profile']['language'] = session[:locale]
    end
  end

end
