require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../shared/login_stubs'
require File.dirname(__FILE__) + '/shared/shared_partner_examples'

describe Retailer::ProfilesController do
  include LoginStubs

  describe "#index on GET" do
    describe "when user is a partner" do
      before(:each) do
        setup_valid_login_credentials_for(Partner)
        @user.stub!(:company).and_return(mock_model(Company, :geo_regions => []))
      end

      it "should respond :success" do
        do_action
        response.should be_success
      end
    	 
      it "should set @location to 'dashboard'" do
        do_action
        assigns[:location].should == 'dashboard'
      end

      it "should set @view_title to 'Dashboard'" do
        do_action
        assigns[:view_title].should == 'Dashboard'
      end
    end

    def do_action
      get 'index'
    end
  end
end
