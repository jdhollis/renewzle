require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/shared/login_stubs'

describe RetailerContentController do
  include LoginStubs
  
  describe "#faq on GET" do
  	it "should respond :success" do
  	  do_action
      response.should be_success
    end

    it "should set @view_title to 'Frequently Asked Questions from Solar Retailers'" do
      do_action
      assigns[:view_title].should == 'Frequently Asked Questions from Solar Retailers'
    end

    it "should set @meta_description to 'Have questions about how your solar business can get more customers with Renewzle? Our FAQ covers cost, lead volume, handling quote requests, interacting with the customer, and more.'" do
      do_action
      assigns[:meta_description].should == 'Have questions about how your solar business can get more customers with Renewzle? Our FAQ covers cost, lead volume, handling quote requests, interacting with the customer, and more.'
    end

    it "should set @meta_keywords to 'renewzle frequently asked questions, renewzle faq, solar power faq, solar system size, solar financial analysis, solar panel rfp'" do
      do_action
      assigns[:meta_keywords].should == 'renewzle frequently asked questions, renewzle faq, solar power faq, solar system size, solar financial analysis, solar panel rfp'
    end
    
    describe "when the user is logged in as a partner" do
      before(:each) do
        setup_valid_login_credentials_for(Partner)
      end
      
      it "should render with the 'partner' layout" do
        controller.expect_render(:layout => 'partner')
        do_action
      end
    end
    
    describe "when the user is logged in (but not as a partner)" do
      before(:each) do
        setup_valid_login_credentials_for(User)
      end
      
      it "should render with the 'pre_signup_partner' layout" do
        controller.expect_render(:layout => 'pre_signup_partner')
        do_action
      end
    end
    
    describe "when the user is not logged in" do
      it "should render with the 'pre_signup_partner' layout" do
        controller.expect_render(:layout => 'pre_signup_partner')
        do_action
      end
    end
    
    def do_action
      get 'faq'
    end
  end
  
  describe "#help on GET" do
  	it "should respond :success" do
  	  do_action
      response.should be_success
    end

    it "should set @view_title to 'How to Use Renewzle to Grow Your Solar Business: Instructions for Retailers &amp; Installers'" do
      do_action
      assigns[:view_title].should == 'How to Use Renewzle to Grow Your Solar Business: Instructions for Retailers &amp; Installers'
    end

    it "should set @meta_description to 'Learn how to sign up for Renewzle and use it to find highly qualified residential solar leads. This document walks you step-by-step through the process of using Renewzle to find customers for your solar business.'" do
      do_action
      assigns[:meta_description].should == 'Learn how to sign up for Renewzle and use it to find highly qualified residential solar leads. This document walks you step-by-step through the process of using Renewzle to find customers for your solar business.'
    end
    
    describe "when the user is logged in as a partner" do
      before(:each) do
        setup_valid_login_credentials_for(Partner)
      end
      
      it "should render with the 'partner' layout" do
        controller.expect_render(:layout => 'partner')
        do_action
      end
    end
    
    describe "when the user is logged in (but not as a partner)" do
      before(:each) do
        setup_valid_login_credentials_for(User)
      end
      
      it "should render with the 'pre_signup_partner' layout" do
        controller.expect_render(:layout => 'pre_signup_partner')
        do_action
      end
    end
    
    describe "when the user is not logged in" do
      it "should render with the 'pre_signup_partner' layout" do
        controller.expect_render(:layout => 'pre_signup_partner')
        do_action
      end
    end
    
    def do_action
      get 'help'
    end
  end
end