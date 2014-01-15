# encoding: utf-8
class VokomokumController < ApplicationController

  skip_before_filter :authenticate, :only => :login
  before_filter :authenticate_finance, :only => :export_amounts

  def login
    request.post? or raise FoodsoftVokomokum::AuthnException.new('Vokomokum login needs POST')

    userinfo = FoodsoftVokomokum.check_user(params[:Mem])
    user = update_or_create_user(userinfo[:id],
                                 userinfo[:email],
                                 userinfo[:first_name],
                                 userinfo[:last_name])
    super user
    redirect_to root_url

  rescue FoodsoftVokomokum::AuthnException => e
    Rails.logger.warn "Vokomokum authentication failed: #{e.message}"
    redirect_to FoodsoftConfig[:vokomokum_members_url]
  end

  def export_amounts
    order = Order.find(params[:order_id])
    amounts = Hash[order.group_orders.map{|go| [go.ordergroup, go.price] }]
    send_data FoodsoftVokomokum.export_amounts(amounts), filename: order.name+'-vers.txt', type: 'text/plain'
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
