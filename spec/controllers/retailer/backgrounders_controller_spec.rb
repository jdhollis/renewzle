require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../shared/login_stubs'
require File.dirname(__FILE__) + '/shared/shared_partner_examples'

describe Retailer::BackgroundersController do
  include LoginStubs

  before(:each) do
    setup_valid_login_credentials_for(Partner)
    @user.stub!(:can_manage_company_backgrounders).and_return(true)
    @user.stub!(:company).and_return(mock_model(Company, :name => "Test"))
  end
  
  describe "#index on GET" do
    before(:each) do
      @company_backgrounder = mock_model(CompanyBackgrounder)
    end

    it "should respond :success" do
      do_action
      response.should be_success
    end

    it "should set @location to 'backgrounders'" do
      do_action
      assigns[:location].should == 'backgrounders'
    end

    it "should set @view_title to 'Company Backgrounders'" do
      do_action
      assigns[:view_title].should == 'Company Backgrounders'
    end

    it "should show list of company backgrounders" do
      CompanyBackgrounder.should_receive(:paginate).with(
        :all, 
        :conditions => ["company_id = ?", @user.company.id], 
        :per_page   => 10, 
        :page       => params[:page]
      ).and_return([@backgrounder])
      do_action
      assigns[:backgrounders].should == [@backgrounder]
    end

    def do_action
      get 'index'
    end
  end
  
  describe "#create on POST" do
    describe "on success create" do
      before(:each) do
        @company_backgrounder_params = {
          "title" => 'test',
          "partner_id" => @user.id,
          "company_id" => @user.company.id,
          "doc" => mock_uploader("/tmp/test.txt")
        }
        stub_create_new_company_backgrounder
        @company_backgrounder.should_receive(:save!)
        @company_backgrounder.should_receive(:title).and_return('Test')
        do_action
      end

      it "should set flash[:notice] to 'Test has been created.'" do
        flash[:notice].should == "Test has been created."
      end

      it "should respond with redirect" do
        response.should be_redirect
        response.should redirect_to(retailer_backgrounders_url)
      end
    end

    describe "when there are validation errors" do
      before(:each) do
        @company_backgrounder_params = {
          "partner_id" => @user.id,
          "company_id" => @user.company.id
        }
        stub_create_new_company_backgrounder
        @company_backgrounder.errors.stub!(:full_messages).and_return([])
        @company_backgrounder.should_receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(@company_backgrounder))
      end

      it "should render 'index'" do
        controller.expect_render(:action => 'index')
        do_action
      end
    end
    
    def do_action
      post 'create', :company_backgrounder => @company_backgrounder_params
    end
  end
  
  describe "#destroy on GET" do
    before(:each) do
      @company_backgrounder_id = '1';
      @company_backgrounder = mock_model(CompanyBackgrounder, :company => @user.company, :title => 'Test')
      CompanyBackgrounder.should_receive(:find).with(@company_backgrounder_id, :conditions => { :company_id => @user.company.id }).and_return(@company_backgrounder)
      @company_backgrounder.company.should == @user.company
      @company_backgrounder.should_receive(:destroy)
      do_action
    end

    it "should set flash[:notice] to 'Test has been removed.'" do
      flash[:notice].should == 'Test has been removed.'
    end

    it "should respond with a redirect" do
      response.should be_redirect
      response.should redirect_to(retailer_backgrounders_url)
    end
		
    def do_action
      delete 'destroy', { :id => @company_backgrounder_id }
    end
		
  end
  
  def stub_create_new_company_backgrounder
    @company_backgrounder = mock_model(CompanyBackgrounder)
    CompanyBackgrounder.should_receive(:new).with(@company_backgrounder_params).and_return(@company_backgrounder)
    @company_backgrounder.should_receive(:waiting_approval=).with(true)
    @company_backgrounder.should_receive(:approved=).with(false)
  end
  
end