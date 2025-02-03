class MessagesController < ApplicationController
  before_action -> { require_plugin_enabled FoodsoftMessages }

  # Renders the "inbox" action.
  def index
    @messages = Message.readable_for(current_user).page(params[:page]).per(@per_page).order('created_at DESC').includes(:sender)
  end

  # Creates a new message object.
  def new
    @message = Message.new(params[:message])

    return unless @message.reply_to

    original_message = Message.find(@message.reply_to)
    @message.reply_to = original_message.reply_to if original_message.reply_to
    if original_message.is_readable_for?(current_user)
      @message.add_recipients [original_message.sender_id]
      @message.group_id = original_message.group_id
      @message.private = original_message.private
      @message.subject = I18n.t('messages.model.reply_subject', subject: original_message.subject)
      @message.body = I18n.t('messages.model.reply_header', user: original_message.sender.display,
                                                            when: I18n.l(original_message.created_at, format: :short)) + "\n"
      @message.body = I18n.t('messages.model.reply_header', user: original_message.sender.display,
                                                            when: I18n.l(original_message.created_at, format: :short)) + "\n" \
      + '<blockquote>' + original_message.body.to_trix_html + '</blockquote>'
    else
      redirect_to new_message_url, alert: I18n.t('messages.new.error_private')
    end
  end

  # Creates a new message.
  def create
    ActiveRecord::Base.transaction do
      @current_user.with_lock do
        @message = @current_user.send_messages.new(params[:message])
        Rails.logger.info "Message column names: #{@message.class.column_names.inspect}"
        if @message.save
          DeliverMessageJob.perform_later(FoodsoftConfig.scope,@message)
          redirect_to messages_url, notice: I18n.t('messages.create.notice')
        else
          Rails.logger.info "Message validation failed with: #{@message.errors.inspect}"
          render :new, status: :unprocessable_entity
          raise ActiveRecord::Rollback
        end
      end
    end
    rescue ActiveRecord::RecordInvalid, ActiveRecord::Rollback => e
      render :new, status: :unprocessable_entity
  end

  # Shows a single message.
  def show
    @message = Message.find(params[:id])
    return if @message.is_readable_for?(current_user)

    redirect_to messages_url, alert: I18n.t('messages.new.error_private')
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
