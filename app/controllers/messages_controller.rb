class MessagesController < ApplicationController

  # Renders the "inbox" action.
  def index
    @messages = Message.public.paginate :page => params[:page], :per_page => 20, :order => 'created_at DESC'
  end

  # Creates a new message object.
  def new
    @message = Message.new(params[:message])
  end

  # Creates a new message.
  def create
    @message = @current_user.send_messages.new(params[:message])
    if @message.save
      Message.delay.deliver(@message.id)
      redirect_to messages_url, :notice => "Nachricht ist gespeichert und wird versendet."
    else
      render :action => 'new'
    end
  end

  # Shows a single message.
  def show
    @message = Message.find(params[:id])
  end
end
