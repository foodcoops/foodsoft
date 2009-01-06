class MessagesController < ApplicationController
  verify :method => :post, :only => [:create, :destroy], :redirect_to => { :action => :index }

  MESSAGE_SEND_SUCCESS = 'Nachricht erfolgreich abgeschickt.'
  MESSAGE_DELETE_SUCCESS = 'Nachricht gelöscht.'
  MESSAGES_DELETE_SUCCESS = 'Nachrichten gelöscht.'
  ERROR_SEND_FAILED = 'Nachricht konnte nicht verschickt werden.'
  ERROR_CANNOT_DELETE = 'Nachricht kann nicht gelöscht werden.'
  ERROR_CANNOT_REPLY = 'Auf diese Nachricht kann nicht geantwortet werden.'
  ERROR_UNKNOWN_USER = 'Unbekannte_r Empfänger_in.'
  ERROR_INVALID_GROUP = 'Empfängergruppe ist unbekannt oder hat keine Mitglieder.'
  ERROR_NO_RECIPIENTS = 'Es sind keine Empfänger_innen ausgewählt.'

  # Renders the "inbox" action.
  def index
    inbox
    render :action => 'inbox'
  end
  
  # Shows the user's message inbox.
  def inbox
    @messages = Message.find_all_by_recipient_id(@current_user.id, :order => 'messages.created_on desc', :include => :sender)
  end
  
  # Creates a new message object.
  def new
    @message = Message.new
  end
  
  # Creates a new message.
  def create
    # Determine recipient(s)...
    @recipient_nicks = ''
    if (params[:everyone] == 'yes')
      @everyone = true
      recipients = User.find(:all)
    else
      recipients = Array.new
      # users      
      for nick in params[:recipient][:nicks].split(%r{,\s*})
        if (user = User.find_by_nick(nick))
          recipients << user
          @recipient_nicks += "#{nick}, "
        end
      end
      @recipient_nicks = @recipient_nicks[0..-3] unless @recipient_nicks.empty?
      # group
      group = Group.find_by_id(params[:recipient][:group_id]) if params[:recipient][:group_id]    
      recipients = recipients | group.users if group
    end
    
    # Construct message(s) and save them...
    if recipients.empty?
      @message = Message.new(params[:message])
      @message.sender = @current_user
      @group = group
      flash[:error] = ERROR_NO_RECIPIENTS
      render :action => 'new'
    else
      begin
        if (@everyone)
          recipients_text = 'alle'
        else
          recipients_text = @recipient_nicks
          recipients_text += (group.nil? ? '' : (recipients_text.empty? ? group.name : ", #{group.name}"))
        end
        Message.transaction do
          for recipient in recipients
            @message = Message.new(
              :subject => params[:message][:subject], 
              :body => params[:message][:body], 
              :recipient => recipient,
              :recipients => recipients_text            
            )
            @message.sender = @current_user
            @message.save!
          end
        end
        flash[:notice] = MESSAGE_SEND_SUCCESS
        redirect_to :action=> 'index'
      rescue
        @group = group
        flash[:error] = ERROR_SEND_FAILED
        render :action => 'new'
      end
    end
  end
  
  # Deletes the message(s) specified by the id/ids param if the current user is the recipient.
  def destroy
    ids = Array.new
    ids << params[:id] if params[:id]
    ids = ids + params[:ids] if (params[:ids] && params[:ids].is_a?(Array))
    for id in ids
      message = Message.find(id)
      if (message && message.recipient && message.recipient == @current_user)
        message.destroy
      else
        flash[:error] = ERROR_CANNOT_DELETE
        break
      end
    end
    flash[:notice] = MESSAGE_DELETE_SUCCESS if (flash[:error].blank? && ids.size == 1)
    flash[:notice] = "#{ids.size} #{MESSAGES_DELETE_SUCCESS}" if (flash[:error].blank? && ids.size > 1)
    redirect_to :action=> 'index'
  end
  
  # Shows a single message.
  def show
    @message = Message.find_by_id_and_recipient_id(params[:id], @current_user.id)
    @message.update_attribute('read', true) if (@message && !@message.read?)
  end

  # Replys to the message specified through :id.
  def reply
    message = Message.find(params[:id])
    if (message && message.recipient && message.recipient == @current_user && message.sender && message.sender.nick)
      @message = Message.new(
        :recipient => message.sender, 
        :subject => "Re: #{message.subject}", 
        :body => "#{message.sender.nick} schrieb am #{FoodSoft::format_date(message.created_on)} um #{FoodSoft::format_time(message.created_on)}:\n"
      )
      if (message.body)
        message.body.each_line{|l| @message.body += "> #{l}"}
      end
      @recipient_nicks = message.sender.nick
      render :action => 'new'
    else
      flash[:error] = ERROR_CANNOT_REPLY
      redirect_to :action=> 'index'
    end
  end

  # Shows new-message form with the recipient user specified through :id.
  def user
    if (recipient = User.find(params[:id]))
      @recipient_nicks = recipient.nick
      @message = Message.new
      render :action => 'new'
    else
      flash[:error] = ERROR_UNKNOWN_USER
      redirect_to :action=> 'index'
    end
  end

  # Shows new-message form with the recipient user specified through :id.
  def group
    recipient = Group.find(params[:id], :include => :memberships)
    if (recipient && !recipient.memberships.empty?)
      @message = Message.new
      @group = recipient
      render :action => 'new'
    else
      flash[:error] = ERROR_INVALID_GROUP
      redirect_to :action=> 'index'
    end
  end

  # Auto-complete for recipient user list.
  def auto_complete_for_recipient_nicks
    @users = User.find(:all, :conditions => ['LOWER(nick) LIKE ?', '%' + params[:recipient][:nicks].downcase + '%'], :order => :nick, :limit => 8)
    render :partial => '/shared/auto_complete_users'
  end
  
  # Returns list of all users as auto-completion hint.
  def user_list
    @users = User.find(:all, :order => :nick)
    render :partial => '/shared/auto_complete_users'
  end
end
