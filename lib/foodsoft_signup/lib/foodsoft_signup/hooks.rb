# adds a membership payment warning to a number of controllers

module FoodsoftSignup

  # show warning on included controllers
  module SignupWarning
    def self.included(base) # :nodoc:
      base.class_eval do
        before_filter Proc.new { FoodsoftSignup.signup_warning self, @current_user }
      end
    end
  end

  def self.signup_warning(c, user)
    unless user.nil?
      if user.ordergroup.nil?
        c.flash.now[:warning] = I18n.t('foodsoft_signup.errors.require_ordergroup')
      elsif !user.ordergroup.approved?
        c.flash.now[:warning] = approval_msg(c)
      end
    end
    return true
  end

  # don't allow ordering unless approved
  module RequireApproval
    def self.included(base) # :nodoc:
      base.class_eval do
        before_filter Proc.new { FoodsoftSignup.check_approval self, @current_user }
      end
    end
  end

  def self.check_approval(c, user)
    # short checks
    user and user.role_admin? and return true
    user and user.ordergroup and user.ordergroup.approved? and return true
    # maybe no access, test if member can go here
    FoodsoftConfig[:ordergroup_approval_for].blank? and return true
    unless FoodsoftConfig[:ordergroup_approval_for].member?("#{c.params[:controller]}") or
           FoodsoftConfig[:ordergroup_approval_for].member?("#{c.action_name}_#{c.params[:controller]}")
      return true
    end
    #phrase = I18n.t("foodsoft_signup.phrases.#{c.action_name}_#{c.controller_name}",
    #  default: I18n.t("foodsoft_signup.phrases.#{c.controller_name}",
    #  default: I18n.t('foodsoft_signup.phrases.fallback')))
    if user.nil? or user.ordergroup.nil?
      c.redirect_to c.root_url, alert: I18n.t('foodsoft_signup.errors.no_ordergroup')
    elsif !user.ordergroup.approved?
      c.redirect_to c.root_url, alert: I18n.t('foodsoft_signup.errors.not_approved')
    end
  end

  def self.approval_msg(c)
    if s = FoodsoftConfig[:ordergroup_approval_payment]
      link = c.class.helpers.link_to(I18n.t('foodsoft_signup.payment.msg_link'), payment_link(c))
      msg = if FoodsoftConfig[:ordergroup_approval_msg]
        FoodsoftConfig[:ordergroup_approval_msg].gsub /%{link}/, link
      else
        I18n.t('foodsoft_signup.payment.msg', link: link)
      end
    else
      msg = (FoodsoftConfig[:ordergroup_approval_msg] or I18n.t('foodsoft_signup.approval.msg'))
    end
    msg
  end

  def self.payment_link(c)
    (s = FoodsoftConfig[:ordergroup_approval_payment]) or return nil
    url = if s.match(/^https?:/i)
      s
    else
      c.send s.to_sym
    end
    url + '?' + {
      amount: FoodsoftConfig[:membership_fee],
      fixed: 'true',
      label: I18n.t('foodsoft_signup.payment.pay_label'),
      title: I18n.t('foodsoft_signup.payment.pay_title')
    }.to_param
  end

end

# now patch desired controllers to include this
ActiveSupport.on_load(:after_initialize) do
  ApplicationController.send :include, FoodsoftSignup::RequireApproval
  [HomeController, GroupOrdersController].each do |controller|
    controller.send :include, FoodsoftSignup::SignupWarning
  end
end
