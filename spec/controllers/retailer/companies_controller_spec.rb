require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../shared/login_stubs'
require File.dirname(__FILE__) + '/../shared/ssl'
require File.dirname(__FILE__) + '/shared/shared_partner_examples'

describe Retailer::CompaniesController do
  include LoginStubs
  include SSL
  
	before(:each) do
	  require_ssl
		@company = mock_model(Company)
	end 

  describe "#edit on GET" do
    it_should_behave_like "a retailer controller"

		describe "when partner does not have proper permissions" do
			before(:each) do
        setup_valid_login_credentials_for(Partner)
				@user.stub!(:can_update_company_profile).and_return(false)
				do_action
			end

 			it "should set flash[:notice] to 'You do not have the permissions to perform that action.'" do
 				flash[:notice].should == 'You do not have the permissions to perform that action.'
 			end

 			it "should respond with a redirect" do
 				response.should be_redirect
 				response.should redirect_to(retailer_dashboard_url)
 			end
		end
    
    describe "when user is a partner" do
      before(:each) do
        setup_valid_login_credentials_for(Partner)
				@user.stub!(:company)
      end

			it "should respond :success" do
				do_action
				response.should be_success
			end
			
			it "should set @location to 'company'" do
				do_action
				assigns[:location].should == 'companies'
			end
			
			it "should set @view_title to 'My Company'" do
				do_action
				assigns[:view_title].should == 'My Company'
			end
    end
		
		def do_action
		  get 'edit'
		end
  end

	describe "#update on POST" do
	  it_should_behave_like "a retailer controller"
	  
	  describe "when user is a partner" do
      before(:each) do
       	setup_valid_login_credentials_for(Partner)
        @company_params = { 'id' => @company_id }
  		end

  		describe "on a successful update" do
  			before(:each) do
					setup_shared_stubs
  				@company.should_receive(:update_from).with(@company_params)
  				do_action
  			end

  			it "should set flash[:notice] to 'Company updated.'" do
  				flash[:notice].should == 'Company updated.'
  			end

  			it "should respond with a redirect" do
  				response.should be_redirect
  				response.should redirect_to(retailer_dashboard_url)
  			end
  		end

  		describe "when there are validation errors" do
  		  before(:each) do
					setup_shared_stubs
  		    @company.errors.stub!(:full_messages).and_return([])
          @company.should_receive(:update_from).with(@company_params).and_raise(ActiveRecord::RecordInvalid.new(@company))
  		  end
  		  
  			it "should render 'edit'" do
          controller.expect_render(:action => 'edit')
  				do_action
  			end
  		end
	  end
	  
	  def do_action
	    post 'update', { :id => @company_id, 'company' => @company_params }
	  end
	end

  def setup_shared_stubs
		@company_id = 1
    @company_params = { 'id' => @company_id }
		@user.stub!(:company).and_return(@company)
  end
end
