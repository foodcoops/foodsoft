class LoginController < ApplicationController
  skip_before_filter :authenticate        # no authentication since this is the login page
  before_filter :validate_token, :only => [:password, :update_password]

  verify :method => :post, :only => [:login, :reset_password, :new], :redirect_to => { :action => :index }
  
  # Redirects to the login action.
  def index
    render :action => 'login'
  end
  
  # Logout the current user and deletes the session
  def logout
    self.return_to = nil 
    current_user = nil
    reset_session
    flash[:notice] = "Abgemeldet"
    render :action => 'login'
  end
  
  # Displays a "denied due to insufficient privileges" message and provides the login form.
  def denied
    flash[:error] = "Du bist nicht berechtigt diese Seite zu besuchen. Bitte als berechtige Benutzerin anmelden oder zurück gehen."
    render :action => 'login'
  end
  
  # Login to the foodsoft.
  def login
    user = User.find_by_nick(params[:login][:user])
    if user && user.has_password(params[:login][:password])
      # Set last_login to Now()
      user.update_attribute(:last_login, Time.now)
      self.current_user = user
      if (redirect = return_to) 
        self.return_to = nil 
        redirect_to redirect
      else
        redirect_to root_path
      end
    else
      current_user = nil
      flash[:error] = "Tschuldige, die Anmeldung war nicht erfolgreich. Bitte erneut versuchen."
    end
  end
  
  # Display the form to enter an email address requesting a token to set a new password.
  def forgot_password
  end
  
  # Sends an email to a user with the token that allows setting a new password through action "password".
  def reset_password
    if (user = User.find_by_email(params[:login][:email]))
      user.reset_password_token = user.new_random_password(16)
      user.reset_password_expires = Time.now.advance(:days => 2)
      if user.save
        email = Mailer.deliver_reset_password(user)
        logger.debug("Sent password reset email to #{user.email}.")
      end
    end
    flash[:notice] = "Wenn Deine E-Mail hier registiert ist bekommst Du jetzt eine Nachricht mit einem Passwort-Zurücksetzen-Link."
    render :action => 'login'
  end
  
  # Set a new password with a token from the password reminder email.
  # Called with params :id => User.id and :token => User.reset_password_token to specify a new password.
  def password
  end
  
  # Sets a new password.
  # Called with params :id => User.id and :token => User.reset_password_token to specify a new password.
  def update_password
    @user.attributes = params[:user]
    if @user.valid?
      @user.reset_password_token = nil
      @user.reset_password_expires = nil
      @user.save
      flash[:notice] = "Dein Passwort wurde aktualisiert. Du kannst Dich jetzt anmelden."
      render :action => 'login'
    else
      render :action => 'password'
    end
  end

  # Invited users.
  def invite
    @invite = Invite.find_by_token(params[:id])
    if (@invite.nil? || @invite.expires_at < Time.now)
      flash[:error] = "Deine Einladung ist nicht (mehr) gültig."
      render :action => 'login'
    elsif @invite.group.nil?
      flash[:error] = "Die Gruppe, in die Du eingeladen wurdest, existiert leider nicht mehr."
      render :action => 'login'
    elsif (request.post?)
      User.transaction do
        @user = User.new(params[:user])
        @user.email = @invite.email
        if @user.save
          Membership.new(:user => @user, :group => @invite.group).save!
          @invite.destroy
          flash[:notice] = "Herzlichen Glückwunsch, Dein Account wurde erstellt. Du kannst Dich nun einloggen."
          render :action => 'login'
        end
      end
    else
      @user = User.new(:email => @invite.email)
    end
  rescue
    flash[:error] = "Ein Fehler ist aufgetreten. Bitte erneut versuchen."
  end

  protected

  def validate_token
    @user = User.find_by_id_and_reset_password_token(params[:id], params[:token])
    if (@user.nil? || @user.reset_password_expires < Time.now)
      flash[:error] = "Ungültiger oder abgelaufener Token. Bitte versuch es erneut."
      render :action => 'forgot_password'
    end
  end
end
