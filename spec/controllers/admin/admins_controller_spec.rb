require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../shared/login_stubs'
require File.dirname(__FILE__) + '/../shared/ssl'
require File.dirname(__FILE__) + '/shared/shared_admin_examples'

describe Admin::AdminsController do
  include LoginStubs
  include SSL
  
  before(:each) do
    require_ssl
  end
  
  describe "#index on GET" do
    it_should_behave_like "an admin controller"
    
    describe "when user is an admin" do
      before(:each) do
        setup_valid_login_credentials_for(Administrator)
      end
      
      it "should respond :success" do
        do_action
        response.should be_success
      end

      it "should setup page javascript" do
        controller.should_receive(:setup_page_javascript).at_least(:once)
        do_action
      end

      it "should show partners waiting approval" do
        Partner.should_receive(:waiting_approval)
        do_action
      end

      it "should show profiles waiting approval" do
        Profile.should_receive(:waiting_approval)
        do_action
      end
      
      it "should show company_backgrounders waiting approval" do
        CompanyBackgrounder.should_receive(:last_waiting_approval)
        do_action
      end
    end
    
    def do_action
      get 'index'
    end
  end
  
  def setup_shared_stubs
  end
end
