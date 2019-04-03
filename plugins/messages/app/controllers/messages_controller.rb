class MessagesController < ApplicationController

  before_filter -> { require_plugin_enabled FoodsoftMessages }

  # Renders the "inbox" action.
  def index
    @messages = Message.pub.page(params[:page]).per(@per_page).order('created_at DESC').includes(:sender)
  end

  # Creates a new message object.
  def new
    @message = Message.new(params[:message])

    if @message.reply_to
      original_message = Message.find(@message.reply_to)
      if original_message.reply_to
        @message.reply_to = original_message.reply_to
      end
      if original_message.is_readable_for?(current_user)
        @message.add_recipients [original_message.sender]
        @message.group_id = original_message.group_id
        @message.private = original_message.private
        @message.subject = I18n.t('messages.model.reply_subject', :subject => original_message.subject)
        @message.body = I18n.t('messages.model.reply_header', :user => original_message.sender.display, :when => I18n.l(original_message.created_at, :format => :short)) + "\n"
        original_message.body.each_line{ |l| @message.body += I18n.t('messages.model.reply_indent', :line => l) }
      else
        redirect_to new_message_url, alert: I18n.t('messages.new.error_private')
      end
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

  def toggle_private
    message = Message.find(params[:id])
    if message.can_toggle_private?(current_user)
      message.update_attribute :private, !message.private
      redirect_to message
    else
      redirect_to message, alert: I18n.t('messages.toggle_private.not_allowed')
    end
  end

  def thread
    @messages = Message.thread(params[:id]).order(:created_at)
  end
end
