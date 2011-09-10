require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../shared/login_stubs'
require File.dirname(__FILE__) + '/../shared/ssl'
require File.dirname(__FILE__) + '/shared/shared_admin_examples'

describe Admin::LeadsController do
  include LoginStubs
  include SSL

	before(:each) do
	  require_ssl
		@lead = mock_model(Lead)
	end 

  describe "#index on GET" do
    it_should_behave_like "an admin controller"
    
    describe "when user is an admin" do
      before(:each) do
        setup_valid_login_credentials_for(Administrator)
        
        @leads = mock('leads')
        Lead.should_receive(:paginate).with(:per_page => 20, :page => params[:page]).and_return(@leads)
        
        do_action
      end
      
      it "should find all leads and assign them to @leads" do
  			assigns[:leads].should be(@leads)
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

  		it "should find the lead to show and assign it to @lead" do
  			assigns[:lead].should be(@lead)
  		end
	  end
	  
	  def do_action
	    get 'show', { :id => @lead_id }
	  end
	end
	
	def stub_lead_find
    @lead_id = '1'
    Lead.should_receive(:find).with(@lead_id).and_return(@lead)
  end
  
  def setup_shared_stubs
    stub_lead_find
  end
end
