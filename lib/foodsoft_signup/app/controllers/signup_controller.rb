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
      @user = User.new(params[:user].reject {|k,v| k=='ordergroup'})
      @group = Ordergroup.new({
        :name => name_from_user(@user),
        :contact_person => @user.name,
        :contact_phone => @user.phone
      }.merge((params[:user][:ordergroup] or {})))
      begin
        User.transaction do
          @user.save! and @group.save!
          Membership.new(:user => @user, :group => @group).save!
          login @user
          url = if !FoodsoftConfig[:membership_fee].nil? and FoodsoftConfig[:ordergroup_approval_payment]
            FoodsoftSignup.payment_link self
          else
            root_url
          end
          redirect_to url, notice: I18n.t('signup.controller.notice')
        end
      rescue => e
        flash[:error] = I18n.t('errors.general_msg', msg: e)
      end
    else
      @user = User.new
      @user.settings.defaults['profile']['language'] = session[:locale]
    end
  end


  protected

  # generate an unique ordergroup name from a user
  # TODO use from ordergroup model, when wvengen/feature-edit_ordergroup_with_user is merged
  def name_from_user(user)
    name = user.display
    suffix = 2
    while Ordergroup.where(name: name).exists? do
      name = "#{user.display} (#{suffix})"
      suffix += 1
    end
    name
  end

end
