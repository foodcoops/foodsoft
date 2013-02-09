class MessagesController < ApplicationController

  # Renders the "inbox" action.
  def index
    @messages = Message.public.page(params[:page]).per(@per_page).order('created_at DESC').includes(:sender)
  end

  # Creates a new message object.
  def new
    @message = Message.new(params[:message])
  end

  # Creates a new message.
  def create
    @message = @current_user.send_messages.new(params[:message])
    if @message.save
      Resque.enqueue(UserNotifier, FoodsoftConfig.scope, 'message_deliver', @message.id)
      redirect_to messages_url, :notice => I18n.t('messages.create.notice')
    else
      render :action => 'new'
    end
  end

  # Shows a single message.
  def show
    @message = Message.find(params[:id])
  end
end
