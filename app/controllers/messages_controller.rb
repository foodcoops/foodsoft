class MessagesController < ApplicationController
  
  # Renders the "inbox" action.
  def index
    @messages = Message.all :order => 'created_at DESC', :limit => 100
  end
    
  # Creates a new message object.
  def new
    @message = Message.new
  end
  
  # Creates a new message.
  def create
    @message = @current_user.send_messages.new(params[:message])
    if @message.save
      #FIXME: Send Mails wit ID instead of using message.state ...
      call_rake :send_emails
      flash[:notice] = "Nachricht ist gespeichert und wird versendet."
      redirect_to messages_path
    else
      render :action => 'new'
    end
  end
  
  # Shows a single message.
  def show
    @message = Message.find(params[:id])
  end

  # Replys to the message specified through :id.
  def reply
    message = Message.find(params[:id])
    @message = Message.new(:recipient => message.sender, :subject => "Re: #{message.subject}")
    @message.body = "#{message.sender.nick} schrieb am #{I18n.l(message.created_at.to_date)} um #{I18n.l(message.created_at, :format => :time)}:\n"
    message.body.each_line{|l| @message.body += "> #{l}"}
    render :action => 'new'
  end

  # Shows new-message form with the recipient user specified through :id.
  def user
    if (recipient = User.find(params[:id]))
      @message = Message.new(:recipient => recipient)
      render :action => 'new'
    else
      flash[:error] = 'Unbekannte_r EmpfängerIn.'
      redirect_to :action=> 'index'
    end
  end

  # Shows new-message form with the recipient user specified through :id.
  def group
    group = Group.find(params[:id], :include => :memberships)
    if (group && !group.memberships.empty?)
      @message = Message.new(:group_id => group.id)
      render :action => 'new'
    else
      flash[:error] = 'Empfängergruppe ist unbekannt oder hat keine Mitglieder.'
      redirect_to :action=> 'index'
    end
  end

  # Auto-complete for recipient user list.
  def auto_complete_for_message_recipients_nicks
    @users = User.find(:all, 
      :conditions => ['LOWER(nick) LIKE ?', '%' + params[:message][:recipients_nicks].downcase + '%'],
      :order => :nick, :limit => 8)
    render :partial => '/shared/auto_complete_users'
  end
  
  # Returns list of all users as auto-completion hint.
  def user_list
    @users = User.find(:all, :order => :nick)
    render :partial => '/shared/auto_complete_users'
  end
end
