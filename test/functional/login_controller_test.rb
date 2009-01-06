require File.dirname(__FILE__) + '/../test_helper'
require 'login_controller'

# Re-raise errors caught by the controller.
class LoginController; def rescue_action(e) raise e end; end

class LoginControllerTest < Test::Unit::TestCase
  
  fixtures :users

  def setup
    @controller = LoginController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @admin = User.find(1)
    @admin.set_password({:required => true}, "secret", "secret")
    @admin.save
    @emails     = ActionMailer::Base.deliveries
    @emails.clear  
  end

  def test_login_with_invalid_user
    post :login, :login => {:user => 'bubu', :password => 'baba'}
    assert_response :success
    assert_equal "Sorry, anmelden nicht möglich",  assigns(:error)
  end
  
  def test_login_with_valid_user
    post :login, :login => {:user => 'admin', :password => 'secret'}
    assert_redirected_to :controller => 'index'
    #assert_not_nil session[:user_nick] #TODO: make this work !
    #user = User.find(session[:user_id])
    #assert_equal 'admin@foo.test', user.email
  end
  
  def test_reset_password_with_invalid_email
    post :reset_password, :login => {:email => "admin@bubu.baba"}
    assert_match "Leider keine passende Emailadresse", flash[:error]
  end
  
  def test_reset_password_and_mail_delivery
    post :reset_password, :login => {:email => "admin@foo.test"}
    assert_redirected_to :action => 'login'
    assert_equal 1, @emails.size  #FIXME: Why this doesn't function ?
    email = @email.first
    assert_match(/admin/, response.subject)
    assert_equal("admin@foo.test", response.to[0])
    assert_match(/Dein Passwort neues lautet: /, response.body)
  end
end