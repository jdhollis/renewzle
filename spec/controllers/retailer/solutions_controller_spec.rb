require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../shared/login_stubs'
require File.dirname(__FILE__) + '/../shared/ssl'
require File.dirname(__FILE__) + '/shared/shared_partner_examples'

describe Retailer::SolutionsController do
  include LoginStubs
  include SSL

	before(:each) do
		@solution = mock_model(Solution)
	end 

  describe "#new on GET" do
    before(:each) do
      require_ssl
    end

	  it_should_behave_like "a retailer controller"
	  
	  describe "when user is a partner" do
      before(:each) do
       	setup_valid_login_credentials_for(Partner)
       	setup_shared_stubs
  			do_action
  		end

  		it "should respond :success" do
  			response.should be_success
  		end

			it "should set @location to 'solutions'" do
				assigns[:location].should == 'solutions'
			end
			
			it "should set @view_title to 'Lead Disposition'" do
				assigns[:view_title].should == 'Lead Disposition'
			end

  		it "should find the lead to show and assign it to @lead" do
  			assigns[:lead].should be(@lead)
  		end
	  end
	  
	  def do_action
	    get 'new', { :id => 1 }
	  end
	end

	describe "#create on POST" do
    before(:each) do
      require_ssl
    end

	  it_should_behave_like "a retailer controller"
	  
	  describe "when user is a partner" do
      before(:each) do
       	setup_valid_login_credentials_for(Partner)
				setup_shared_stubs
        @solution_params = { 'lead_id' => @lead_id }
				Solution.should_receive(:new).with(@solution_params).and_return(@solution)
  		end

  		describe "on a successful update" do
  			before(:each) do
  				@solution.should_receive(:save!)
  				do_action
  			end

  			it "should set flash[:notice] to 'Lead disposition saved.'" do
  				flash[:notice].should == 'Lead disposition saved.'
  			end

  			it "should respond with a redirect" do
  				response.should be_redirect
  				response.should redirect_to(retailer_leads_url)
  			end
  		end

  		describe "when there are validation errors" do
  		  before(:each) do
  		    @solution.errors.stub!(:full_messages).and_return([])
          @solution.should_receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(@solution))
  		  end
  		  
  			it "should render 'new'" do
          controller.expect_render(:action => 'new')
  				do_action
  			end
  		end
	  end
	  
	  def do_action
	    post 'create', { 'solution' => @solution_params }
	  end
	end
	
	def stub_lead_find
		@lead_id = '1'
		@lead = mock_model(Lead)
		@lead.stub!(:customer).and_return(mock_model(User, :full_name => 'Peter Griffin'))
		@leads.stub!(:find).with(@lead_id).and_return(@lead)
	end
	
	def setup_shared_stubs
		@leads = mock('leads', :paginate => [])
		@user.stub!(:leads).and_return(@leads)
		stub_lead_find
	end
end
