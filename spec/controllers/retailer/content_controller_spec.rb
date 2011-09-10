require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../shared/login_stubs'
require File.dirname(__FILE__) + '/shared/shared_partner_examples'
require File.dirname(__FILE__) + '/../shared/shared_content_examples'

describe Retailer::ContentController do
  include LoginStubs
  
  describe "#about" do
    it_should_behave_like "a retailer controller"
    
    def do_action
      get 'about'
    end
  end
  
  describe "#privacy_policy" do
    it_should_behave_like "a retailer controller"
    
    def do_action
      get 'privacy_policy'
    end
  end
  
  describe "#tos" do
    it_should_behave_like "a retailer controller"
    
    def do_action
      get 'tos'
    end
  end
  
  it_should_behave_like "a controller that provides access to 'About'"
  it_should_behave_like "a controller that provides access to 'Privacy Policy'"
  it_should_behave_like "a controller that provides access to 'Terms of Service'"
  
  def perform_additional_before_actions
    setup_valid_login_credentials_for(Partner)
  end
end