require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/shared/ssl'

describe PartnersController do
  include SSL

  describe "#new on GET" do
    before(:each) do
      require_ssl
    end

    describe "when not xhr?" do
      it "should respond :success" do
        get 'new'
        response.should be_success
      end

      it "should set @location to 'partner_signup'" do
        get 'new'
        assigns[:location].should == 'partner_signup'
      end

      it "should set @view_title to 'Solar Energy Installers & Professionals – Register to Find Sales Leads at Renewzle'" do
        get 'new'
        assigns[:view_title].should == 'Solar Energy Installers & Professionals – Register to Find Sales Leads at Renewzle'
      end

      it "should set @meta_description to 'Solar installers and retailers, get matched with highly qualified sales leads for residential solar panel sales. Homeowners interested in solar energy installations are waiting for you.'" do
        get 'new'
        assigns[:meta_description].should == 'Solar installers and retailers, get matched with highly qualified sales leads for residential solar panel sales. Homeowners interested in solar energy installations are waiting for you.'
      end

      it "should set @meta_keywords to 'solar panel sales leads, solar power leads, solar installer leads, residential solar energy, solar rfp, solar lead generation, solar power installation jobs'" do
        get 'new'
        assigns[:meta_keywords].should == 'solar panel sales leads, solar power leads, solar installer leads, residential solar energy, solar rfp, solar lead generation, solar power installation jobs'
      end
    end
    
    describe "when xhr?" do
      describe "and provided with a valid company id" do
        before(:each) do
          @id = '1'
        end
        
        it "should find and set @company to the Company" do
          mock_company
          xhr :get, 'new', { 'id' => @id }
          assigns[:company].should be(@company)
        end
        
        it "should set @partner to a new Partner" do
          mock_company
          @partner = stub_model(Partner)
          @partner.stub!(:first_name)
          @partner.stub!(:last_name)
          @partner.stub!(:email)
          @partner.stub!(:password)
          @partner.stub!(:password_confirmation)
          @partner.stub!(:phone_number)
          @partner.stub!(:fax_number)
          @partner.stub!(:errors).and_return(mock(Array, :invalid? => {}, :on => nil))
          Partner.should_receive(:new).and_return(@partner)
          xhr :get, 'new', { 'id' => @id }
          assigns[:partner].should be(@partner)
        end
        
        def mock_company
          @company = stub_model(Company)
          @company.stub!(:name)
          @company.stub!(:email)
          @company.stub!(:url)
          @company.stub!(:street_address)
          @company.stub!(:city)
          @company.stub!(:state)
          @company.stub!(:postal_code)
          @company.stub!(:country)
          @company.stub!(:phone_number)
          @company.stub!(:fax_number)
          @company.stub!(:installs)
          @company.stub!(:installs?)
          @company.stub!(:total_kw_installed)
          @company.stub!(:contractors_license_number)
          @company.stub!(:in_business_since)
          @company.stub!(:errors).and_return(mock(Array, :invalid? => {}, :on => nil))
          Company.should_receive(:find).with(@id).and_return(@company)
        end
      end
    end
  end
  
  describe "#create on POST" do
    before(:each) do
      require_ssl
    end

    it "should wrap the signup in a transaction on Company" do
      Company.should_receive(:transaction)
      controller.stub!(:login)
      post 'create'
    end
    
    describe "on a successful signup" do
      before(:each) do
        @company_id = '1'
        @company = stub_model(Company)
        @partner = stub_model(Partner)
        @params = { 'partner' => 'params', 'company' => { 'id' => @company_id } }
      end
      
      it "should find the company the partner is signing up and store it in @company" do
        Company.should_receive(:find).with(@company_id).and_return(@company)
        @company.stub!(:register).and_return(@partner)
        @company.stub!(:update_from)
        stub_login
        post 'create', @params
        assigns[:company].should be(@company)
      end
      
      it "should register the partner with the company and store in @partner" do
        Company.stub!(:find).and_return(@company)
        @company.should_receive(:register).with(@params['partner']).and_return(@partner)
        @company.stub!(:update_from)
        stub_login
        post 'create', @params
        assigns[:partner].should be(@partner)
      end
      
      it "should update the company's attributes from params" do
        Company.stub!(:find).and_return(@company)
        @company.stub!(:register).and_return(@partner)
        @company.should_receive(:update_from).with(@params['company'])
        stub_login
        post 'create', @params
      end
      
      it "should log the partner in" do
        stub_company
        @login_token = stub_model(LoginToken)
        @login_token.stub!(:value)
        @partner.should_receive(:login!).and_return(@login_token)
        post 'create', @params
      end
      
      it "should set flash[:notice] to 'Thanks for signing up! We'll be contacting you shortly.'" do
        stub_company
        stub_login
        post 'create', @params
        flash[:notice].should == "Thanks for signing up! We'll be contacting you shortly."
      end

      it "should redirect to the partner dashboard" do
        stub_company
        stub_login
        post 'create', @params
        response.should be_redirect
        response.should redirect_to(retailer_dashboard_url)
      end
      
      def stub_company
        Company.stub!(:find).and_return(@company)
        @company.stub!(:register).and_return(@partner)
        @company.stub!(:update_from)
      end
    end
    
    describe "on an unsuccessful signup when there are validation errors" do
      before(:each) do
        @company_id = '1'
        @company = stub_model(Company)
        @partner = Partner.new  # had to use a real ActiveRecord to save having to stub out all the error bullshit for the exception below
        @params = { 'partner' => 'params', 'company' => { 'id' => @company_id } }
        Company.stub!(:find).and_return(@company)
        @company.stub!(:register).and_return(@partner)
        @company.stub!(:update_from).and_raise(ActiveRecord::RecordInvalid.new(@partner))
      end
      
      it "should respond :success" do
        post 'create', @params
        response.should be_success
      end

      it "should set @location to 'partner_signup'" do
        post 'create', @params
        assigns[:location].should == 'partner_signup'
      end

      it "should set @view_title to 'Solar Energy Installers & Professionals – Register to Find Sales Leads at Renewzle'" do
        post 'create', @params
        assigns[:view_title].should == 'Solar Energy Installers & Professionals – Register to Find Sales Leads at Renewzle'
      end

      it "should set @meta_description to 'Solar installers and retailers, get matched with highly qualified sales leads for residential solar panel sales. Homeowners interested in solar energy installations are waiting for you.'" do
        post 'create', @params
        assigns[:meta_description].should == 'Solar installers and retailers, get matched with highly qualified sales leads for residential solar panel sales. Homeowners interested in solar energy installations are waiting for you.'
      end

      it "should set @meta_keywords to 'solar panel sales leads, solar power leads, solar installer leads, residential solar energy, solar rfp, solar lead generation, solar power installation jobs'" do
        post 'create', @params
        assigns[:meta_keywords].should == 'solar panel sales leads, solar power leads, solar installer leads, residential solar energy, solar rfp, solar lead generation, solar power installation jobs'
      end
      
      it "should set flash[:warning] to 'Please review and correct the validation errors below before resubmitting.'" do
        post 'create', @params
        flash[:warning].should == 'Please review and correct the validation errors below before resubmitting.'
      end
      
      it "should set flash[:company_name] to the company's name from params (for the search form)" do
        @params['company_name'] = 'Renewzle'
        post 'create', @params
        flash[:company_name].should == 'Renewzle'
      end
      
      it "should render 'new'" do
        controller.expect_render(:action => 'new')
        post 'create', @params
      end
    end
    
    def stub_login
      @login_token = stub_model(LoginToken)
      @login_token.stub!(:value)
      @partner.stub!(:login!).and_return(@login_token)
    end
  end
end
