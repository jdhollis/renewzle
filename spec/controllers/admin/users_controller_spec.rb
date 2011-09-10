require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../shared/login_stubs'
require File.dirname(__FILE__) + '/../shared/ssl'
require File.dirname(__FILE__) + '/shared/shared_admin_examples'

describe Admin::UsersController do
  include LoginStubs
  include SSL

	before(:each) do
	  require_ssl
	  @user = mock_model(User)
	end

  describe "#index on GET" do	
    it_should_behave_like "an admin controller"
    
    describe "when user is an admin" do
      before(:each) do
        setup_valid_login_credentials_for(Administrator)
        
        @users = mock('user')
        User.should_receive(:paginate).with(:order => 'email', :per_page => 20, :page => params[:page]).and_return(@users)
        
        do_action
      end
      
      it "should find all users and assign them to @users" do
  			assigns[:users].should be(@users)
  		end
    end
		
		def do_action
		  get 'index'
		end
		
		def setup_shared_stubs
	  end
  end

	describe "#show on GET" do
	  it_should_behave_like "an admin controller"
	  
	  describe "when user is an admin" do
      before(:each) do
       	setup_valid_login_credentials_for(Administrator)
       	setup_shared_stubs
  			do_action
  		end

  		it "should respond :success" do
  			response.should be_success
  		end

  		it "should find the user to show and assign it to @user" do
  			assigns[:user].should be(@user)
  		end
	  end
	  
	  def do_action
	    get 'show', { :id => @user_id }
	  end
	end

	describe "#edit on GET" do	  
	  it_should_behave_like "an admin controller"
	  
	  describe "when user is an admin" do
      before(:each) do
       	setup_valid_login_credentials_for(Administrator)
       	User.should_receive(:find).and_return(@user)
       	do_action
  		end

  		it "should respond :success" do
  			response.should be_success
  		end

  		it "should find the user to edit and assign it to @user" do
  			assigns[:user].should be(@user)
  		end
	  end
		
		def do_action
		  get 'edit', { :id => @user_id }
		end
	end

	describe "#update on POST" do
	  it_should_behave_like "an admin controller"
	  
	  describe "when user is an admin" do
      before(:each) do
       	setup_valid_login_credentials_for(Administrator)
 		  end

      describe "when request is normal" do
        before(:each) do
          stub_user_find
          @user_params = { 'id' => @user_id }
  		  end

  		  describe "on a successful update" do
  		  	before(:each) do
  		  		@user.should_receive(:update_from).with(@user_params)
  		  		@user.should_receive(:email).and_return('jd@greenoptions.com')
  		  		do_action
  		  	end

  		  	it "should set flash[:notice] to '\#{@user.email} updated.'" do
  		  		flash[:notice].should == 'jd@greenoptions.com updated.'
  		  	end

  		  	it "should respond with a redirect" do
  		  		response.should be_redirect
  		  		response.should redirect_to(admin_users_url)
  		  	end
  		  end

  		  describe "when there are validation errors" do
  		    before(:each) do
  		      @user.errors.stub!(:full_messages).and_return([])
            @user.should_receive(:update_from).with(@user_params).and_raise(ActiveRecord::RecordInvalid.new(@user))
  		    end
  		    
  		  	it "should render 'edit'" do
            controller.expect_render(:action => 'edit')
  		  		do_action
  		  	end
  		  end
      end

      describe "when request is xhr" do
        before(:each) do
          @partner = mock_model(Partner)
        end

        it "should approve partner when 'approve' is selected" do
          @partner_params = { :id => '1', :partner => { :waiting_approval => 'approve' } }
          Partner.should_receive(:find).with(@partner_params[:id]).and_return(@partner)
          @partner.should_receive(:approve!)
          xhr :post, 'update', @partner_params
        end

        it "should decline partner when 'decline' is selected" do
          @partner_params = { :id => '1', :partner => { :waiting_approval => 'decline' } }
          Partner.should_receive(:find).with(@partner_params[:id]).and_return(@partner)
          @partner.should_receive(:decline!)
          xhr :post, 'update', @partner_params
        end
      end
	  end
	  
	  def do_action
	    post 'update', { :id => @user_id, 'user' => @user_params }
	  end
	  
	  def setup_shared_stubs
	    stub_user_find
	    @user_params = { 'id' => @user_id }
	    @user.should_receive(:update_from).with(@user_params)
	    @user.should_receive(:email).and_return('jd@greenoptions.com')
	  end
	end

	describe "#destroy on GET" do
	  it_should_behave_like "an admin controller"
	  
	  describe "when user is an admin" do
	    before(:each) do
       	setup_valid_login_credentials_for(Administrator)
       	setup_shared_stubs
        do_action
  		end

  		it "should set flash[:notice] to '\#{@user.email} has been removed.'" do
  			flash[:notice].should == 'jd@greenoptions.com has been removed.'
  		end

  		it "should respond with a redirect" do
  			response.should be_redirect
  			response.should redirect_to(admin_users_url)
  		end
	  end
		
		def do_action
		  delete 'destroy', { :id => @user_id }
		end
		
		def setup_shared_stubs
		  stub_user_find
		  @user.should_receive(:email).and_return('jd@greenoptions.com')
		  @user.should_receive(:destroy)
		end
	end

  def stub_user_find
    @user_id = '1'
    User.should_receive(:find).with(@user_id).and_return(@user)
  end
  
  def setup_shared_stubs
    stub_user_find
  end
end
