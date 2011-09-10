class SessionsController < ApplicationController
	layout 'shared'	
  
  ssl_required :new, :create, :destroy, :forgot_password, :reset_password
  
  def new
    @location = 'login'
    @view_title = 'Login'
    @meta_description = 'Login to Renewzle to find the right solar power system for your home, and get quote from solar installers and retailers.'
    @meta_keywords = 'renewzle login, renewzle account, solar financial analysis, solar system size, solar panel cost, solar installers, solar retailers, solar power comparison'

		@user = User.new
  end
  
  def create
    if @user = User.authenticate(params['email'], params['password'])
      login(@user)
      redirect_to(session[:destination_url] || default_url)
    else
      flash[:warning] = 'Invalid email or password.'
      flash[:previously_submitted_email] = params['email']
      redirect_to(login_url)
    end
  end
  
  def destroy
    validate_login_credentials_if_any
    if !@user.blank? && @user.masquerading?
      cookies.delete('remembered_profile_id') if @user.masquerading_as?(Profile)
      @user.stop_masquerading!
    end
    @login_token.destroy unless @login_token.blank?
    cookies.delete('login_token_value')
    reset_session
    redirect_to(login_url)
  end
  
  def forgot_password
		unless request.post?
		  @view_title = 'Forget your password?'
      @user = User.new
    else
      if @user = User.find_by_email(params['user']['email'])
			  @user.set_for_password_reset!
			  Notifier.deliver_forgot_password(@user)
			  flash[:notice] = 'A link for resetting your password has been sent to you by email. Follow the link to reset your password.'
    	  redirect_to(login_url)
    	else
    		flash[:warning] = "We can't seem to find your email address. Have you registered and confirmed your account?"
        redirect_to(forgot_password_url)
  	  end
	  end
	end
	
	def reset_password
	  if @user = User.find_by_password_reset_key(params[:key])
	    unless request.put?
	      @view_title = 'Reset Your Password'
      else
        user_kind = @user.class.to_s.downcase
  		  @user.reset_password_to(params[user_kind]['password'], params[user_kind]['password_confirmation'])
  			flash[:notice] = 'Your password has been reset. You may now log in.'
      	redirect_to(login_url)
      end
    else
      flash[:warning] = 'Your password reset key is invalid. If you believe you\'ve received this message in error, please contact us at <a href=\"mailto:support@renewzle.com\">support@renewzle.com</a>.'
      redirect_to(forgot_password_url)
    end
	end
end
