require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../shared/login_stubs'
require File.dirname(__FILE__) + '/shared/shared_partner_examples'

describe Retailer::LeadsController do
  include LoginStubs

	before(:each) do
		@lead = mock_model(Lead)
	end 

  describe "#index on GET" do
    it_should_behave_like "a retailer controller"
    
    describe "when user is a partner" do
      before(:each) do
        setup_valid_login_credentials_for(Partner)
  			setup_shared_stubs
      end

			it "should respond :success" do
				do_action
				response.should be_success
			end
			
			it "should set @location to 'leads'" do
				do_action
				assigns[:location].should == 'leads'
			end
			
			it "should set @view_title to 'My Leads'" do
				do_action
				assigns[:view_title].should == 'My Leads'
			end

			describe "leads filtering" do
				it "should find all leads and assign them to @leads when params[:filter] is nil" do
					@leads.should_receive(:paginate).with(:per_page => 20, :page => params[:page]).and_return(@leads)
      	  do_action
  				assigns[:leads].should be(@leads)
					assigns[:filter].should == 'all'
  			end

				it "should find all open leads and assign the to @leads when params[:filter] is 'open'" do
					@leads.should_receive(:paginate).with(:conditions => { :closed => false }, :per_page => 20, :page => params[:page]).and_return(@leads)
					get 'index', { :filter => 'open' }
					assigns[:filter].should == 'open'
				end

				it "should find all closed leads and assign the to @leads when params[:filter] is 'closed'" do
					@leads.should_receive(:paginate).with(:conditions => { :closed => true }, :per_page => 20, :page => params[:page]).and_return(@leads)
					get 'index', { :filter => 'closed' }
					assigns[:filter].should == 'closed'
				end
			end
    end
		
		def do_action
		  get 'index'
		end
  end
  
  describe "#show on GET" do
    before(:each) do
      request.stub!(:ssl?).and_return(true)
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

			it "should set @location to 'leads'" do
				assigns[:location].should == 'leads'
			end
			
			it "should set @view_title to 'Lead for 'Peter Griffin''" do
				assigns[:view_title].should == "Lead for 'Peter Griffin'"
			end

  		it "should find the lead to show and assign it to @lead" do
  			assigns[:lead].should be(@lead)
  		end
	  end
	  
	  def do_action
	    get 'show', { :id => @lead_id }
	  end
	end

  describe "#edit on GET" do
    before(:each) do
      request.stub!(:ssl?).and_return(true)
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

			it "should set @location to 'leads'" do
				assigns[:location].should == 'leads'
			end
			
			it "should set @view_title to 'Purchase Lead'" do
				assigns[:view_title].should == "Purchase Lead"
			end

  		it "should find the lead to show and assign it to @lead" do
  			assigns[:lead].should be(@lead)
  		end
	  end
	  
	  def do_action
	    get 'edit', { :id => @lead_id }
	  end
	end

	describe "#update on POST" do
    before(:each) do
      request.stub!(:ssl?).and_return(true)
    end

	  it_should_behave_like "a retailer controller"
	  
	  describe "when user is a partner" do
      before(:each) do
       	setup_valid_login_credentials_for(Partner)
				setup_shared_stubs
        @lead_params = { 'id' => @lead_id }
  		end

			describe "when request is normal" do
  			describe "on a successful update" do
  				before(:each) do
            @lead.should_receive(:ip_address=)
            @lead.should_receive(:attributes=).with(@lead_params)
  					@lead.should_receive(:purchase!)
  					do_action
  				end

  				it "should set flash[:notice] to 'Thanks for purchasing a lead.'" do
  					flash[:notice].should == 'Thanks for purchasing a lead.'
  				end

  				it "should respond with a redirect" do
  					response.should be_redirect
  					response.should redirect_to(retailer_lead_url(@lead))
  				end
  			end

        describe "when credit card is invalid" do
          before(:each) do
            @lead.should_receive(:ip_address=)
            @lead.should_receive(:attributes=).with(@lead_params)
  			    @lead.errors.stub!(:full_messages).and_return([])
  			    @lead.errors.stub!(:add_to_base)
      	    @lead.should_receive(:purchase!).and_raise(Renewzle::CreditCardInvalid)
          end

          it "should render edit" do
      	    controller.should_receive(:exception).and_return(mock('exception', :message => {}))
      	    controller.expect_render(:action => 'edit')
  					do_action
          end
        end

  			describe "when there are validation errors" do
  			  before(:each) do
            @lead.should_receive(:ip_address=)
            @lead.should_receive(:attributes=).with(@lead_params)
  			    @lead.errors.stub!(:full_messages).and_return([])
      	    @lead.should_receive(:purchase!).and_raise(ActiveRecord::RecordInvalid.new(@lead))
  			  end
  			  
  				it "should render 'edit'" do
      	    controller.expect_render(:action => 'edit')
  					do_action
  				end
  			end
			end

			describe "when is request is xhr?" do
				before(:each) do
					@lead.should_receive(:update_from)
				end

				it "should respond with a redirect to retailer_lead_disposition_url if the lead is closed" do
					@lead.should_receive(:closed?).and_return(true)
					xhr :put, 'update', @lead_params
				end
			end
	  end
	  
	  def do_action
	    post 'update', { :id => @lead_id, 'lead' => @lead_params }
	  end
	end
	
	def stub_lead_find
    @lead_id = '1'
    @lead = mock_model(Lead)
		@lead.stub!(:profile).and_return(mock_model(Profile))
		@lead.stub!(:customer).and_return(mock_model(User, :full_name => 'Peter Griffin'))
    @lead.stub!(:set_billing_information_from)
		@leads.stub!(:find).with(@lead_id).and_return(@lead)
  end
  
  def setup_shared_stubs
   	@leads = mock('leads', :paginate => [])
		@user.stub!(:leads).and_return(@leads)
		stub_lead_find
  end
end
