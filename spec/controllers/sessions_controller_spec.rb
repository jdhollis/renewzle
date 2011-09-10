require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/shared/login_stubs'
require File.dirname(__FILE__) + '/shared/ssl'

describe SessionsController do
  include LoginStubs
  include SSL
  
  describe "#new on GET" do
    before(:each) do
      require_ssl
    end
    
    it "should respond :success" do
      get 'new'
      response.should be_success
    end
    
    it "should set @location to 'login'" do
      get 'new'
      assigns[:location].should == 'login'
    end
    
    it "should set @view_title to 'Login'" do
      get 'new'
      assigns[:view_title].should == 'Login'
    end
    
    it "should set @meta_description to 'Login to Renewzle to find the right solar power system for your home, and get quote from solar installers and retailers.'" do
      get 'new'
      assigns[:meta_description].should == 'Login to Renewzle to find the right solar power system for your home, and get quote from solar installers and retailers.'
    end
    
    it "should set @meta_keywords to 'renewzle login, renewzle account, solar financial analysis, solar system size, solar panel cost, solar installers, solar retailers, solar power comparison'" do
      get 'new'
      assigns[:meta_keywords].should == 'renewzle login, renewzle account, solar financial analysis, solar system size, solar panel cost, solar installers, solar retailers, solar power comparison'
    end
  end
  
  describe "#create on POST" do
    before(:each) do
      require_ssl
    end
    
    describe "when authentication fails" do
      before(:each) do
        email = mock('email')
        password = mock('password')
        User.should_receive(:authenticate).with(email, password).and_return(nil)
        post 'create', { 'email' => email, 'password' => password }
      end
      
      it "should set flash[:warning] to 'Invalid email or password.'" do
        flash[:warning].should == 'Invalid email or password.'
      end
      
      it "should set flash[:previously_submitted_email] to params['email']" do
        flash[:previously_submitted_email].should be(params['email'])
      end
      
      it "should redirect to login_url" do
        response.should be_redirect
        response.should redirect_to(login_url)
      end
    end
    
    describe "when authentication succeeds" do  
      before(:each) do
        @email = mock('email')
        @password = mock('password')
        @user = mock_model(User)
        @user.stub!(:masquerading?).and_return(false)
        User.should_receive(:authenticate).with(@email, @password).and_return(@user)
      end
      
      it "should set @user to the authenticated user" do
        stub_login_token_and_user
        do_post
        assigns[:user].should be(@user)
      end
      
      it "should tell @user to login!" do
        stub_login_token
        @user.should_receive(:login!).and_return(@login_token)
        do_post
      end
      
      it "should set @login_token to the token returned by @user.login!" do
        stub_login_token_and_user
        do_post
        assigns[:login_token].should be(@login_token)
      end
      
      it "should set a 'login_token_value' cookie with @login_token.value that expires 3 months from now" do
        stub_login_token_and_user
        do_post
        cookies['login_token_value'].first.should == @login_token_value
      end
      
      describe "if session[:destination_url] is set" do
        it "should redirect to session[:destination_url]" do
          stub_login_token_and_user
          destination = 'https://test.host:80/logout'
          session[:destination_url] = destination
          do_post
          response.should be_redirect
          response.should redirect_to(destination)
        end
      end
      
      describe "if session[:destination_url] is not set" do
        it "should redirect to default_url" do
          stub_login_token_and_user
          default = 'https://test.host:80/logout'
          controller.should_receive(:default_url).and_return(default)
          do_post
          response.should be_redirect
          response.should redirect_to(default)
        end
      end
      
      def stub_login_token_and_user
        stub_login_token
        @user.stub!(:login!).and_return(@login_token)
      end
      
      def stub_login_token
        @login_token_value = 'login token value'
        @login_token = mock_model(LoginToken)
        @login_token.stub!(:value).and_return(@login_token_value)
      end
      
      def do_post
        post 'create', { 'email' => @email, 'password' => @password }
      end
    end
  end
  
  describe "#destroy on GET" do
    before(:each) do
      require_ssl
    end
    
    it "should destroy @login_token if not blank?" do
      setup_valid_login_credentials_for(User)
      @user.should_receive(:masquerading?).and_return(false)
      @login_token.should_receive(:blank?).and_return(false)
      @login_token.should_receive(:destroy)
      get 'destroy'
    end
    
    it "should delete the 'login_token_value' cookie" do
      setup_valid_login_credentials_for(User)
      @user.should_receive(:masquerading?).and_return(false)
      @login_token.stub!(:destroy)
      cookies.should_not have_key('login_token_value')
      get 'destroy'
    end
    
    it "should reset the session" do
      controller.should_receive(:reset_session)
      get 'destroy'
    end
    
    it "should redirect to login_url" do
      get 'destroy'
      response.should be_redirect
      response.should redirect_to(login_url)
    end
  end
  
  describe "#forgot_password" do
    before(:each) do
      require_ssl
    end

    describe "on GET" do    
  		before(:each) do
  		  @user = mock_model(User)
  		  User.should_receive(:new).and_return(@user)
  			do_action
  		end

      it "should respond :success" do
        response.should be_success
      end

      it "should set @view_title to 'Forget your password?'" do
        assigns[:view_title].should == 'Forget your password?'
      end

      it "should set @user to a new user" do
        assigns[:user].should be(@user)
      end

  		def do_action
  			get 'forgot_password'
  		end
    end

    describe "on POST" do    
  		describe "when user email does exist" do
  			before(:each) do
  				@user = mock_model(User)
  				User.should_receive(:find_by_email).with('russ@greenoptions.com').and_return(@user)
  				@user.should_receive(:set_for_password_reset!)
      		Notifier.should_receive(:deliver_forgot_password).with(@user).and_return(true)

      		post 'forgot_password', { :user => { :email => 'russ@greenoptions.com' } }
  			end

      	it "should set flash[:notice] to 'A link for resetting your password has been sent to you by email. Follow the link to reset your password.'" do
      	  flash[:notice].should == 'A link for resetting your password has been sent to you by email. Follow the link to reset your password.'
      	end

      	it "should redirect to login_url" do
  				response.should be_redirect
  				response.should redirect_to(login_url)
      	end
  		end

  		describe "when user email does not exist" do
  			before(:each) do
  				@user = mock_model(User)
    			User.should_receive(:find_by_email).with('russ@greenoptions.com').and_return(nil)

  				post 'forgot_password', { :user => { :email => 'russ@greenoptions.com' } }
  			end

  			it "should set flash[:warning] to 'We can't seem to find your email address. Have you registered and confirmed your account?'" do
  				flash[:warning].should == "We can't seem to find your email address. Have you registered and confirmed your account?"
  			end

  			it "should redirect to forgot_password_url" do
  				response.should be_redirect
  				response.should redirect_to(forgot_password_url)
      	end
  		end
    end
  end
  
  describe "#reset_password" do
    before(:each) do
      require_ssl
    end

    describe "on GET" do
      describe "when the reset key is valid" do
        before(:each) do
          require_ssl
    			@user = mock_model(User)
    			User.should_receive(:find_by_password_reset_key).with('12345').and_return(@user)
    			get 'reset_password', { :key => '12345' }
    		end

        it "should respond :success" do
          response.should be_success
        end

        it "should set @user to the user associated with the reset key" do
          assigns[:user].should be(@user)
        end

        it "should set @view_title to 'Reset Your Password'" do
          assigns[:view_title].should == 'Reset Your Password'
        end
      end
      
      describe "when the reset key is invalid" do
        before(:each) do
          require_ssl
          User.should_receive(:find_by_password_reset_key).with('12345').and_return(nil)
          get 'reset_password', { :key => '12345' }
        end
        
        it "should set flash[:warning] to 'Your password reset key is invalid. If you believe you\'ve received this message in error, please contact us at <a href=\"mailto:support@renewzle.com\">support@renewzle.com</a>.'" do
          flash[:warning].should == 'Your password reset key is invalid. If you believe you\'ve received this message in error, please contact us at <a href=\"mailto:support@renewzle.com\">support@renewzle.com</a>.'
        end
        
        it "should redirect to forgot_password_url" do
          response.should be_redirect
          response.should redirect_to(forgot_password_url)
        end
      end
    end

    describe "on PUT" do    
  		describe "when the reset key is valid" do
  			before(:each) do
          require_ssl
  				@user = mock_model(User)
  				User.should_receive(:find_by_password_reset_key).with('12345').and_return(@user)
  				@user.should_receive(:reset_password_to).with('test', 'test')
          put 'reset_password', { :key => '12345', :user => { :password => 'test', :password_confirmation => 'test' } }
  			end

      	it "should set flash[:notice] to 'Your password has been reset. You may now log in.'" do
  				flash[:notice].should == 'Your password has been reset. You may now log in.'
      	end

  			it "should redirect to login_url" do
  				response.should be_redirect
  				response.should redirect_to(login_url)
  			end
  		end

  		describe "when the reset key is invalid" do
  			before(:each) do
          require_ssl
          @user = mock_model(User)
          User.should_receive(:find_by_password_reset_key).with('12345').and_return(nil)
          put 'reset_password', { :key => '12345', :user => { :password => 'test', :password_confirmation => 'test' } }
  			end

      	it "should set flash[:warning] to 'Your password reset key is invalid. If you believe you\'ve received this message in error, please contact us at <a href=\"mailto:support@renewzle.com\">support@renewzle.com</a>.'" do
  				flash[:warning].should == 'Your password reset key is invalid. If you believe you\'ve received this message in error, please contact us at <a href=\"mailto:support@renewzle.com\">support@renewzle.com</a>.'
      	end
      	
      	it "should redirect to forgot_password_url" do
          response.should be_redirect
          response.should redirect_to(forgot_password_url)
        end
  		end
    end
  end
end
