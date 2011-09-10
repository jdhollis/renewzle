require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../shared/login_stubs'
require File.dirname(__FILE__) + '/../shared/ssl'
require File.dirname(__FILE__) + '/shared/shared_admin_examples'

describe Admin::CompaniesController do
  include LoginStubs
  include SSL

  before(:each) do
    require_ssl
    @company = mock_model(Company)
  end

  describe "#index on GET" do	
    it_should_behave_like "an admin controller"
    
    describe "when user is an admin" do
      before(:each) do
        setup_valid_login_credentials_for(Administrator)
      end
			
      it "should find all companies and assign them to @companies" do
        @companies = mock('claimed companies')
        Company.should_receive(:paginate).with(:order => 'name', :per_page => 20, :page => params[:page]).and_return(@companies)
        do_action
        assigns[:companies].should be(@companies)
      end

      describe "filter un/claimed companies" do			
      	it "should find all claimed companies and assign them to @claimed_companies" do
          @claimed_companies = mock('claimed companies')
          Company.should_receive(:paginate).with(:conditions => { :claimed => true }, :order => 'name', :per_page => 20, :page => params[:page]).and_return(@claimed_companies)
          get 'index', :filter => 'claimed'
          assigns[:filter].should == 'claimed'
        end
  			
        it "should find all unclaimed companies and assign them to @unclaimed_companies" do
          @unclaimed_companies = mock('unclaimed companies')
          Company.should_receive(:paginate).with(:conditions => { :claimed => false }, :order => 'name', :per_page => 20, :page => params[:page]).and_return(@unclaimed_companies)
          get 'index', :filter => 'unclaimed'
          assigns[:filter].should == 'unclaimed'
        end
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

      it "should find the company to show and assign it to @company" do
        assigns[:company].should be(@company)
      end
    end
	  
    def do_action
      get 'show', { :id => @company_id }
    end
  end

  describe "#edit on GET" do	  
    it_should_behave_like "an admin controller"
	  
    describe "when user is an admin" do
      before(:each) do
       	setup_valid_login_credentials_for(Administrator)
       	Company.should_receive(:find).and_return(@company)
       	do_action
      end

      it "should respond :success" do
        response.should be_success
      end

      it "should find the company to edit and assign it to @company" do
        assigns[:company].should be(@company)
      end
    end
		
    def do_action
      get 'edit', { :id => @company_id }
    end
  end

  describe "#update on POST" do
    it_should_behave_like "an admin controller"
	  
    describe "when user is an admin" do
      before(:each) do
       	setup_valid_login_credentials_for(Administrator)
        stub_company_find
        @company_params = { 'id' => @company_id }
      end

      describe "on a successful update" do
        before(:each) do
          @company.should_receive(:update_from).with(@company_params)
          @company.should_receive(:name).and_return('Renewzle')
          do_action
        end

        it "should set flash[:notice] to '\#{@company.name} updated.'" do
          flash[:notice].should == 'Renewzle updated.'
        end

        it "should respond with a redirect" do
          response.should be_redirect
          response.should redirect_to(admin_companies_url)
        end
      end

      describe "when there are validation errors" do
        before(:each) do
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
	  
    def setup_shared_stubs
      stub_company_find
      @company_params = { 'id' => @company_id }
      @company.should_receive(:update_from).with(@company_params)
      @company.should_receive(:name).and_return('Renewzle')
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

      it "should set flash[:notice] to '\#{@company.name} has been removed.'" do
        flash[:notice].should == 'Renewzle has been removed.'
      end

      it "should respond with a redirect" do
        response.should be_redirect
        response.should redirect_to(admin_companies_url)
      end
    end
		
    def do_action
      delete 'destroy', { :id => @company_id }
    end
		
    def setup_shared_stubs
      stub_company_find
      @company.should_receive(:name).and_return('Renewzle')
      @company.should_receive(:destroy)
    end
  end

  def stub_company_find
    @company_id = '1'
    Company.should_receive(:find).with(@company_id).and_return(@company)
  end
  
  def setup_shared_stubs
    stub_company_find
  end
end
