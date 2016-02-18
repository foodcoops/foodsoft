class MessageThreadsController < ApplicationController

  before_filter -> { require_plugin_enabled FoodsoftMessages }

  def index
    @message_threads = Message.pub.threads.page(params[:page]).per(@per_page).order(created_at: :desc).includes(:sender)
  end

  def show
    @messages = Message.thread(params[:id]).order(:created_at)
  end
end
