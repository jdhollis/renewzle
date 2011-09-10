require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/shared/login_stubs'
require File.dirname(__FILE__) + '/shared/profile_stubs'
require File.dirname(__FILE__) + '/shared/shared_customer_examples'
require File.dirname(__FILE__) + '/shared/ssl'

describe CustomersController do
  include LoginStubs
  include ProfileStubs
  include SSL
  
  describe "#create on POST" do
    before(:each) do
      @customer_params = { 'email' => 'jd@greenoptions.com' }
    end
    
    it_should_behave_like "a controller that recalls a remembered profile or redirects to new_profile_url"
    
    describe "when there is a remembered profile" do
      before(:each) do
        setup_remembered_profile
      end
      
      describe "on a successful signup" do
        before(:each) do
          @customer = mock_model(Customer)
          Customer.should_receive(:new).with(@customer_params).and_return(@customer)
          @customer.should_receive(:profile=).with(@profile)
          @customer.should_receive(:save!)
          
          @customer.should_receive(:profile).and_return(@profile)
          @profile.should_receive(:request_quotes!)
          
          @login_token = mock_model(LoginToken)
          @login_token.stub!(:value)
          @customer.stub!(:login!).and_return(@login_token)
        end
        
        it "should set @customer to a new customer created from params and associated with the remembered profile" do
          do_action
          assigns[:customer].should be(@customer)
        end
        
        it "should delete the invalid remembered_profile_id cookie" do
          do_action
          response.cookies['remembered_profile_id'].should be_blank
        end
        
        it "should log the customer in" do
          @customer.should_receive(:login!).and_return(@login_token)
          do_action
        end
        
        #it "should set flash[:notice] to 'Signup successful. A verification link was sent to your email address. Please follow that link to complete your request for quotes.'" do
        #  do_action
        #  flash[:notice].should == 'Signup successful. A verification link was sent to your email address. Please follow that link to complete your request for quotes.'
        #end
        
        it "should set flash[:notice] to 'Signup successful. Your request for quotes has been submitted.'" do
          do_action
          flash[:notice].should == 'Signup successful. Your request for quotes has been submitted.'
        end
        
        it "should redirect to shop_url" do
          do_action
          response.should be_redirect
          response.should redirect_to(shop_url)
        end
        
        #describe "if session[:current_tab_url] is set" do
        #  before(:each) do
        #    session[:current_tab_url] = '/explore'
        #  end
          
        #  it "should redirect to session[:current_tab_url]" do
        #    do_action
        #    response.should be_redirect
        #    response.should redirect_to('/explore')
        #  end
        #end
        
        #describe "if session[:current_tab_url] is not set" do
        #  it "should redirect to explore_url" do
        #    do_action
        #    response.should be_redirect
        #    response.should redirect_to(explore_url)
        #  end
        #end
      end
      
      describe "on an unsuccessful signup when there are validation errors" do
        before(:each) do
          @customer = mock_model(Customer)
          Customer.should_receive(:new).with(@customer_params).and_return(@customer)
          @customer.should_receive(:profile=).with(@profile)
          @customer.errors.stub!(:full_messages).and_return([])
          @customer.should_receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(@customer))
        end
        
        it_should_behave_like "a controller performing an 'explore' action"

        it "should respond :success" do
          do_action
          response.should be_success
        end

        it "should set @view_title to 'Request Quotes'" do
          do_action
          assigns[:view_title].should == 'Request Quotes'
        end
        
        it "should set flash[:warning] to 'Please review and correct the validation errors below before resubmitting.'" do
          do_action
          flash[:warning].should == 'Please review and correct the validation errors below before resubmitting.'
        end
        
        it "should render ContentController#request_quotes" do
          controller.expect_render(:template => 'content/request_quotes')
          do_action
        end
      end
    end
    
    def stub_additional_methods_on_success
      @customer = mock_model(Customer)
      Customer.stub!(:new).and_return(@customer)
      @customer.stub!(:profile=)
      @customer.stub!(:save!)
      @login_token = mock_model(LoginToken)
      @login_token.stub!(:value)
      @customer.stub!(:login!).and_return(@login_token)
      @customer.stub!(:profile).and_return(@profile)
      @profile.stub!(:request_quotes!)
    end
    
    def do_action
      post 'create', { 'customer' => @customer_params }
    end
  end
	
	describe "#edit on GET" do
    before(:each) do
      require_ssl
    end
    
    it_should_behave_like "a controller performing a customer-only action"

    describe "when the user is logged in as a customer" do
      before(:each) do
        setup_valid_login_credentials_for(Customer)
				setup_shared_stubs
				do_action
      end

			it "should assign :user to :customer" do
				assigns[:customer].should == @user
			end

			it "should set :view_title to 'My Account'" do
				assigns[:view_title].should == 'My Account'
			end

			it "should set :location to 'my_account'" do
				assigns[:location].should == 'my_account'
			end
		end

		def do_action
			get 'edit'
		end

		def setup_shared_stubs
			@user.stub!(:profile).and_return(stub_model(Profile))
		end
	end

	describe "#update on POST" do
    before(:each) do
      require_ssl
    end
    
    it_should_behave_like "a controller performing a customer-only action"

    describe "when the user is logged in as a customer" do
      before(:each) do
				@customer_params = {}
        setup_valid_login_credentials_for(Customer)
				setup_shared_stubs
      end

			describe "on successful update" do
				before(:each) do
					@user.should_receive(:update_from).and_return(true)
					do_action
				end

				it "should set flash[:notice] to 'Your account has been updated.'" do
					flash[:notice].should == 'Your account has been updated.'
				end

				it "should respond with a redirect" do
					response.should be_redirect
					response.should redirect_to(edit_customer_url)
				end
			end

			describe "on unsuccessful update" do
				before(:each) do
          @user.errors.stub!(:full_messages).and_return([])
          @user.should_receive(:update_from).and_raise(ActiveRecord::RecordInvalid.new(@user))
				end

				it "should set :view_title to 'My Account'" do
					do_action
					assigns[:view_title].should == 'My Account'
				end

				it "should set :location to 'my_account'" do
					do_action
					assigns[:location].should == 'my_account'
				end

				it "should render :action 'edit'" do
					controller.expect_render(:action => 'edit')
					do_action
				end
			end
		end

		def do_action
			post 'update', @customer_params
		end

		def setup_shared_stubs
			@user.stub!(:profile).and_return(stub_model(Profile))
		end
	end

	describe "#update on POST" do
    it_should_behave_like "a controller performing a customer-only action"

    describe "when the user is logged in as a customer" do
      before(:each) do
        setup_valid_login_credentials_for(Customer)
				setup_shared_stubs
				@user.should_receive(:destroy)
				do_action
      end

			it "set flash[:notice] to 'Your account has been cancelled.'" do
				flash[:notice].should == 'Your account has been cancelled.'
			end

			it "should respond with a redirect" do
				response.should be_redirect
				response.should redirect_to(explore_url)
			end
		end

		def do_action
			get 'destroy'
		end

		def setup_shared_stubs
			@user.stub!(:profile).and_return(stub_model(Profile))
		end
	end

#  describe "#verify on GET" do
#    before(:each) do
#      @verification_code = '12345'
#    end
    
#    describe "with a valid verification code" do
#      before(:each) do
#        @user = mock_model(Customer)
#        Customer.should_receive(:find_by_verification_code).with(@verification_code).and_return(@user)
        
#        @profile = mock_model(Profile)
#        @login_token = mock_model(LoginToken)
#        @login_token.stub!(:value)
#      end
      
#      it "should set @user to the customer found using the verification code" do
#        stub_methods_on_success
#        do_action
#        assigns[:user].should be(@user)
#      end
      
#      it "should verify! the customer" do
#        @user.should_receive(:verify!)
#        @profile.stub!(:request_quotes!)
#        @user.stub!(:profile).and_return(@profile)
#        @user.stub!(:login!).and_return(@login_token)
#        do_action
#      end
      
#      it "should request quotes on the user's profile" do
#        @user.stub!(:verify!)
#        @user.should_receive(:profile).and_return(@profile)
#        @profile.should_receive(:request_quotes!)
#        @user.stub!(:login!).and_return(@login_token)
#        do_action
#      end
      
#      it "should set flash[:notice] to 'Thanks for verifying your email address. Your request for quotes has been submitted.'" do
#        stub_methods_on_success
#        do_action
#        flash[:notice].should == 'Thanks for verifying your email address. Your request for quotes has been submitted.'
#      end
      
#      it "should log the customer in" do
#        @user.stub!(:verify!)
#        @profile.stub!(:request_quotes!)
#        @user.stub!(:profile).and_return(@profile)
#        @user.should_receive(:login!).and_return(@login_token)
#        do_action
#      end
      
#      it "should redirect to shop_url" do
#        stub_methods_on_success
#        do_action
#        response.should be_redirect
#        response.should redirect_to(shop_url)
#      end
      
#      def stub_methods_on_success
#        @user.stub!(:verify!)
#        @profile.stub!(:request_quotes!)
#        @user.stub!(:profile).and_return(@profile)
#        @user.stub!(:login!).and_return(@login_token)
#      end
#    end
    
#    describe "with an invalid verification code" do
#      before(:each) do
#        Customer.should_receive(:find_by_verification_code).with(@verification_code).and_return(nil)
#      end
      
#      it "should set flash[:warning] to 'Invalid verification code. If you need help logging in or verifying your email address, please contact us at <a href=\"mailto:support@renewzle.com\">support@renewzle.com</a>.'" do
#        do_action
#        flash[:warning].should == 'Invalid verification code. If you need help logging in or verifying your email address, please contact us at <a href="mailto:support@renewzle.com">support@renewzle.com</a>.'
#      end

#      it "should redirect to learn_url" do
#        do_action
#        response.should be_redirect
#        response.should redirect_to(learn_url)
#      end
#    end
    
#    def do_action
#      get 'verify', { 'verification_code' => @verification_code }
#    end
#  end
end
