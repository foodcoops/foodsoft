class MessagesController < ApplicationController

  before_filter -> { require_plugin_enabled FoodsoftMessages }

  # Renders the "inbox" action.
  def index
    @messages = Message.public.page(params[:page]).per(@per_page).order('created_at DESC').includes(:sender)
  end

  # Creates a new message object.
  def new
    @message = Message.new(params[:message])
    if @message.reply_to and not @message.reply_to.is_readable_for?(current_user)
      redirect_to new_message_url, alert: 'Nachricht ist privat!'
    end
  end

  # Creates a new message.
  def create
    @message = @current_user.send_messages.new(params[:message])
    if @message.save
      Resque.enqueue(MessageNotifier, FoodsoftConfig.scope, 'message_deliver', @message.id)
      redirect_to messages_url, :notice => I18n.t('messages.create.notice')
    else
      render :action => 'new'
    end
  end

  # Shows a single message.
  def show
    @message = Message.find(params[:id])
    unless @message.is_readable_for?(current_user)
      redirect_to messages_url, alert: 'Nachricht ist privat!'
    end
  end
end
