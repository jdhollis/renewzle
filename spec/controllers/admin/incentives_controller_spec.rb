require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../shared/login_stubs'
require File.dirname(__FILE__) + '/../shared/ssl'
require File.dirname(__FILE__) + '/shared/shared_admin_examples'

describe Admin::IncentivesController do
  include LoginStubs
  include SSL

	before(:each) do
	  require_ssl
		@incentive = mock_model(Incentive)
	end 

  describe "#index on GET" do
    it_should_behave_like "an admin controller"
    
    describe "when user is an admin" do
      before(:each) do
        setup_valid_login_credentials_for(Administrator)
        
        @incentives = mock('incentives')
        Incentive.should_receive(:paginate).with(:per_page => 20, :page => params[:page]).and_return(@incentives)
        
        do_action
      end
      
      it "should find all incentives and assign them to @incentives" do
  			assigns[:incentives].should be(@incentives)
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

  		it "should find the incentive to show and assign it to @incentive" do
  			assigns[:incentive].should be(@incentive)
  		end
	  end
	  
	  def do_action
	    get 'show', { :id => @incentive_id }
	  end
	end

	describe "#edit on GET" do	  
	  it_should_behave_like "an admin controller"
	  
	  describe "when user is an admin" do
      before(:each) do
       	setup_valid_login_credentials_for(Administrator)
       	Incentive.should_receive(:find).and_return(@incentive)
       	do_action
  		end

  		it "should respond :success" do
  			response.should be_success
  		end

  		it "should find the incentive to edit and assign it to @incentive" do
  			assigns[:incentive].should be(@incentive)
  		end
	  end
		
		def do_action
		  get 'edit', { :id => @incentive_id }
		end
	end

	describe "#update on POST" do
	  it_should_behave_like "an admin controller"
	  
	  describe "when user is an admin" do
      before(:each) do
       	setup_valid_login_credentials_for(Administrator)
        stub_incentive_find
        @incentive_params = { 'id' => @incentive_id }
  		end

  		describe "on a successful update" do
  			before(:each) do
  				@incentive.should_receive(:update_from).with(@incentive_params)
  				do_action
  			end

  			it "should set flash[:notice] to 'Incentive updated.'" do
  				flash[:notice].should == 'Incentive updated.'
  			end

  			it "should respond with a redirect" do
  				response.should be_redirect
  				response.should redirect_to(admin_incentives_url)
  			end
  		end

  		describe "when there are validation errors" do
  		  before(:each) do
  		    @incentive.errors.stub!(:full_messages).and_return([])
          @incentive.should_receive(:update_from).with(@incentive_params).and_raise(ActiveRecord::RecordInvalid.new(@incentive))
  		  end
  		  
  			it "should render 'edit'" do
          controller.expect_render(:action => 'edit')
  				do_action
  			end
  		end
	  end
	  
	  def do_action
	    post 'update', { :id => @incentive_id, 'incentive' => @incentive_params }
	  end
	  
	  def setup_shared_stubs
	    stub_incentive_find
	    @incentive_params = { 'id' => @incentive_id }
	    @incentive.should_receive(:update_from).with(@incentive_params)
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

  		it "should set flash[:notice] to 'Incentive has been removed.'" do
  			flash[:notice].should == 'Incentive has been removed.'
  		end

  		it "should respond with a redirect" do
  			response.should be_redirect
  			response.should redirect_to(admin_incentives_url)
  		end
	  end
		
		def do_action
		  delete 'destroy', { :id => @incentive_id }
		end
		
		def setup_shared_stubs
		  stub_incentive_find
		  @incentive.should_receive(:destroy)
		end
	end
	
	def stub_incentive_find
    @incentive_id = '1'
    Incentive.should_receive(:find).with(@incentive_id).and_return(@incentive)
  end
  
  def setup_shared_stubs
    stub_incentive_find
  end
end
