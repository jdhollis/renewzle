require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/shared/login_stubs'
require File.dirname(__FILE__) + '/shared/profile_stubs'
require File.dirname(__FILE__) + '/shared/ssl'
require File.dirname(__FILE__) + '/shared/shared_customer_examples'

describe LeadsController do
  include LoginStubs
  include SSL
  
  describe "#new on GET" do
    before(:each) do
      require_ssl
      @quote_id = '1'
    end
    
    it_should_behave_like "a controller performing a customer-only action"
    
    describe "when the user is logged in as a customer" do
      before(:each) do
        setup_valid_login_credentials_for(Customer)
      end
      
      describe "and a quote to accept can be found" do
        before(:each) do
          @quote = mock_model(Quote)
          Quote.should_receive(:find).with(@quote_id).and_return(@quote)
          @partner = mock_model(Partner)
          @quote.should_receive(:partner).and_return(@partner)
          @profile = mock_model(Profile)
          @quote.should_receive(:profile).and_return(@profile)
          @profile.stub!(:set_address_from)
          @lead = mock_model(Lead)
          Lead.should_receive(:new).with({ :quote => @quote, :partner => @partner, :profile => @profile }).and_return(@lead)
        end
        
        it_should_behave_like "a controller performing a 'shop' action"
        
        it "should set @view_title to 'Accept quote?'" do
          do_action
          assigns[:view_title].should == 'Accept quote?'
        end
        
        it "should set @quote to the quote to accept" do
          do_action
          assigns[:quote].should be(@quote)
        end
        
        it "should set @partner to the partner who made the quote" do
          do_action
          assigns[:partner].should be(@partner)
        end
        
        it "should set @profile to the profile to which the quote responds" do
          do_action
          assigns[:profile].should be(@profile)
        end
        
        it "should set @lead to a new lead initialized with @quote, @partner, and @profile" do
          do_action
          assigns[:lead].should be(@lead)
        end
      end
      
      describe "and a quote to accept can't be found" do
        before(:each) do
          Quote.should_receive(:find).with(@quote_id).and_raise(ActiveRecord::RecordNotFound)
        end
        
        it "should respond :missing" do
          do_action
          response.should be_missing
        end
        
        it "should render 404" do
          controller.expect_render(:file => 'public/404.html', :status => 404)
          do_action
        end
      end
    end
    
    def do_action
      get 'new', { :id => @quote_id }
    end
  end
  
  describe "#create on POST" do
    before(:each) do
      require_ssl
      @lead_params = { 'quote_id' => '1', 'partner_id' => '1' }
      @profile_id = '1'
      @profile_params = { 'id' => @profile_id }
    end
    
    it_should_behave_like "a controller performing a customer-only action"
    
    describe "when the user is logged in as a customer" do
      before(:each) do
        setup_valid_login_credentials_for(Customer)
      end
      
      describe "and the profile associated with the quote can be found" do
        before(:each) do
          @profile = mock_model(Profile)
          Profile.should_receive(:find).with(@profile_id).and_return(@profile)
          @lead = mock_model(Lead)
          Lead.should_receive(:new).with(@lead_params).and_return(@lead)
          @lead.stub!(:profile=)
          @lead.should_receive(:save!)
        end
        
        it "should set @lead to a new lead initialized from params" do
          do_action
          assigns[:lead].should be(@lead)
        end

        it "should set @profile to the associated profile" do
          do_action
          assigns[:profile].should be(@profile)
        end
        
        it "should set @lead.profile to @profile" do
          @lead.should_receive(:profile=).with(@profile)
          do_action
        end
        
        it "should set flash[:notice] to 'Quote accepted. Expect to be contacted by the partner shortly.'" do
          do_action
          flash[:notice].should == 'Quote accepted. Expect to be contacted by the partner shortly.'
        end
        
        it "should redirect to shop_url" do
          do_action
          response.should be_redirect
          response.should redirect_to(shop_url)
        end
      end
      
      describe "and the profile associated with the quote can't be found" do
        before(:each) do
          Profile.should_receive(:find).with(@profile_id).and_raise(ActiveRecord::RecordNotFound)
        end
        
        it "should respond :missing" do
          do_action
          response.should be_missing
        end
        
        it "should render 404" do
          controller.expect_render(:file => 'public/404.html', :status => 404)
          do_action
        end
      end
    end
    
    def do_action
      post 'create', { 'lead' => @lead_params, 'profile' => @profile_params }
    end
  end
end
