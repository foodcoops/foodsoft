class MessageThreadsController < ApplicationController
  before_action -> { require_plugin_enabled FoodsoftMessages }

  def index
    @groups = Group.order(:name)
  end

  def show
    @group = Group.find_by_id(params[:id])
    @message_threads = Message.readable_for(current_user).threads.where(group: @group).page(params[:page]).per(@per_page).order(created_at: :desc)
  end
end
