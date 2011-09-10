require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../shared/login_stubs'
require File.dirname(__FILE__) + '/../shared/ssl'
require File.dirname(__FILE__) + '/shared/shared_admin_examples'
 
describe Admin::BackgroundersController do
  include LoginStubs
  include SSL
  
  before(:each) do
    require_ssl
    @company_backgrounder = mock_model(CompanyBackgrounder)
  end 
  
  describe "#index on GET" do
    it_should_behave_like "an admin controller"
    
    describe "when user is an admin" do
      before(:each) do
        setup_valid_login_credentials_for(Administrator)
        @per_page = 20
      end
      
      it "should respond :success" do
        do_action
        response.should be_success
      end

      it "should find all company backgrounders waiting for approval" do
        @company_backgrounders_waiting_approval = mock('company backgrounders waiting approval')
        CompanyBackgrounder.should_receive(:paginate).with(
          :conditions => { :waiting_approval => true }, 
          :order      => 'created_at', 
          :per_page   => @per_page, 
          :page       => params[:page]
        ).and_return(@company_backgrounders_waiting_approval)
        do_action
        assigns[:company_backgrounders].should be(@company_backgrounders_waiting_approval)
      end
      
      describe "filter company backgrounders by status" do
        it "should find all company backgrounders" do
          @company_backgrounders = mock('company backgrounders')
          CompanyBackgrounder.should_receive(:paginate).with(
            :order    => 'title', 
            :per_page => @per_page, 
            :page     => params[:page]
          ).and_return(@company_backgrounders)
          get 'index', :filter => 'all'
          assigns[:filter].should == 'all'
        end
        
        it "should find approved company backgrounders" do
          @approved_company_backgrounders = mock('approved company backgrounders')
          CompanyBackgrounder.should_receive(:paginate).with(
            :conditions => { :waiting_approval => false, :approved => true }, 
            :order      => 'reviewed_at', 
            :per_page   => @per_page, 
            :page       => params[:page]
          ).and_return(@approved_company_backgrounders)
          get 'index', :filter => 'approved'
          assigns[:filter].should == 'approved'
        end
        
        it "should find rejected company backgrounders" do
          @rejected_company_backgrounders = mock('rejected company backgrounders')
          CompanyBackgrounder.should_receive(:paginate).with(
            :conditions => { :waiting_approval => false, :approved => false }, 
            :order      => 'reviewed_at', 
            :per_page   => @per_page, 
            :page       => params[:page]
          ).and_return(@rejected_company_backgrounders)
          get 'index', :filter => 'rejected'
          assigns[:filter].should == 'rejected'
        end
      end
    end
    
    def do_action
      get 'index'
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
          stub_company_backgrounder_find
          @company_backgrounder_params = { 'id' => @profile_backgrounder_id }
        end
        
        describe "on a success update" do
          before(:each) do
            @company_backgrounder.should_receive(:update_attributes).with(@company_backgrounder_params).and_return(true)
          end
          
          it "should set flash[:notice] to 'CompanyBackgrounder was successfully updated.'" do
            do_action
            flash[:notice].should == 'CompanyBackgrounder was successfully updated.'
          end

          it "should respond with a redirect" do
            do_action
            response.should be_redirect
            response.should redirect_to(admin_backgrounders_url)
          end
        end
        
        describe "when there are validation errors" do
          before(:each) do
            @company_backgrounder.errors.stub!(:full_messages).and_return([])
            @company_backgrounder.should_receive(:update_attributes).with(@company_backgrounder_params).and_return(false)
          end
  		    
          it "should render 'edit'" do
            controller.expect_render(:action => 'edit')
            do_action
          end
        end
      end
      
      describe "when request is xhr" do
        before(:each) do
          @company_backgrounder = stub_model(CompanyBackgrounder, :wating_approval => true)
        end

        it "should approve company_backgrounder when 'approve' is selected" do
          @company_backgrounder_params = { :id => '1', :backgrounder => { :waiting_approval => 'approve' } }
          CompanyBackgrounder.should_receive(:find).with(@company_backgrounder_params[:id]).and_return(@company_backgrounder)
          @company_backgrounder.should_receive(:approve)
          xhr :post, 'update', @company_backgrounder_params
        end

        it "should redirect to 'decline reason' when 'decline' is selected" do
          @company_backgrounder_params = { :id => '1', :backgrounder => { :waiting_approval => 'decline' } }
          CompanyBackgrounder.should_receive(:find).with(@company_backgrounder_params[:id]).and_return(@company_backgrounder)
          xhr :post, 'update', @company_backgrounder_params
#          controller.expect_render(:update)
#          response.should redirect_to(reject_admin_backgrounders_url(@company_backgrounder))
        end
      end
    end
    
    def do_action
      post 'update', { :id => @company_backgrounder_id, :company_backgrounder => @company_backgrounder_params }
    end
    
    def setup_shared_stubs
      stub_company_backgrounder_find
      @company_backgrounder_params = { 'id' => @company_backgrounder_id }
      @company_backgrounder.should_receive(:update_attributes).with(@company_backgrounder_params)
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

      it "should set flash[:notice] to 'Company Backgrounder has been removed.'" do
        flash[:notice].should == 'Company Backgrounder has been removed.'
      end

      it "should respond with a redirect" do
        response.should be_redirect
        response.should redirect_to(admin_backgrounders_url)
      end
    end
		
    def do_action
      delete 'destroy', { :id => @company_backgrounder_id }
    end
		
    def setup_shared_stubs
      stub_company_backgrounder_find
      @company_backgrounder.should_receive(:destroy)
    end
  end
  
  describe "#approve on GET" do
    it_should_behave_like "an admin controller"
	  
    describe "when user is an admin" do
      before(:each) do
       	setup_valid_login_credentials_for(Administrator)
       	setup_shared_stubs
        do_action
      end

      it "should respond with a redirect" do
        response.should be_redirect
        response.should redirect_to(admin_backgrounders_url)
      end
    end
		
    def do_action
      get 'approve', { :id => @company_backgrounder_id }
    end
		
    def setup_shared_stubs
      stub_company_backgrounder_find
      @company_backgrounder.should_receive(:approve)
    end
  end
  
  describe "#confirm_reject on GET" do
    it_should_behave_like "an admin controller"
	  
    describe "when user is an admin" do
      before(:each) do
       	setup_valid_login_credentials_for(Administrator)
       	setup_shared_stubs
        do_action
      end

      it "should respond with a redirect" do
        response.should be_redirect
        response.should redirect_to(admin_backgrounders_url)
      end
    end
		
    def do_action
      get 'confirm_reject', { :id => @company_backgrounder_id, :company_backgrounder => { :comments => @comments } }
    end
		
    def setup_shared_stubs
      stub_company_backgrounder_find
      @comments = "test"
      @company_backgrounder.should_receive(:reject).with(@comments)
    end
  end
  
  def stub_company_backgrounder_find
    @company_backgrounder_id = '1'
    CompanyBackgrounder.should_receive(:find).with(@company_backgrounder_id).and_return(@company_backgrounder)
  end
  
  def setup_shared_stubs
  end
end
