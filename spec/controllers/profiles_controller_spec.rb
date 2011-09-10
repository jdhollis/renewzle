require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/shared/login_stubs'
require File.dirname(__FILE__) + '/shared/profile_stubs'
require File.dirname(__FILE__) + '/shared/shared_customer_examples'

describe ProfilesController do
  include LoginStubs
  include ProfileStubs
  
  describe "#new on GET" do
    it "should respond :success" do
      do_action
      response.should be_success
    end
    
    it_should_behave_like "a controller performing a 'learn' action"
    
    it "should set @tab to 'get_started'" do
      do_action
      assigns[:tab].should == 'get_started'
    end
    
    it "should set session[:current_tab_url] to new_profile_url" do
      do_action
      session[:current_tab_url].should == new_profile_url
    end
    
    it "should set @view_title to 'Get Started'" do
      do_action
      assigns[:view_title].should == 'Get Started'
    end
    
    it_should_behave_like "a controller that recalls a remembered profile or creates a new one"
    
    def do_action
      get 'new'
    end
  end
  
  describe "#create on POST" do
    before(:each) do
      @profile = stub_model(Profile)
      @profile_params = { 'postal_code' => '94044' }
    end
    
    describe "on a successful profile creation" do      
      it "should create a new profile from params, tell it to validate the postal_code, and store it in @profile" do
        Profile.should_receive(:new).with(@profile_params.merge('validate_postal_code' => true)).and_return(@profile)
        @profile.should_receive(:save!)
        @profile.stub!(:is_owned?).and_return(false)
        do_action
        assigns[:profile].should be(@profile)
      end
      
      describe "when the user is logged in" do
        describe "as a customer" do
          before(:each) do
            setup_valid_login_credentials_for(Customer)
            @profile.should_receive(:is_owned?).and_return(true)
          end

          it "should associate the profile with the customer" do
            Profile.should_receive(:new).with(@profile_params.merge('customer' => @user, 'validate_postal_code' => true)).and_return(@profile)
            @profile.should_receive(:save!)
            do_action
          end

          it "should not remember the profile with a cookie" do
            Profile.stub!(:new).and_return(@profile)
            @profile.stub!(:save!)
            do_action
            response.cookies['remembered_profile_id'].should be_blank
          end
        end
        
        describe "as anything other than a customer" do
          before(:each) do
            setup_valid_login_credentials_for(User)
          end
          
          it "should remember the profile by setting cookies['remembered_profile_id'] to the id of the newly created profile" do
            Profile.stub!(:new).and_return(@profile)
            @profile.stub!(:save!)
            @profile.should_receive(:is_owned?).and_return(false)
            @profile.should_receive(:to_param).and_return('1')
            do_action
            response.cookies['remembered_profile_id'][0].should == '1'
          end
        end
      end
      
      describe "when the user is not logged" do
        it "should remember the profile by setting cookies['remembered_profile_id'] to the id of the newly created profile" do
          Profile.stub!(:new).and_return(@profile)
          @profile.stub!(:save!)
          @profile.should_receive(:is_owned?).and_return(false)
          @profile.should_receive(:to_param).and_return('1')
          do_action
          response.cookies['remembered_profile_id'][0].should == '1'
        end
      end
      
      it "should redirect to new_profile_url" do
        Profile.stub!(:new).and_return(@profile)
        @profile.stub!(:save!)
        @profile.stub!(:is_owned?).and_return(false)
        do_action
        response.should be_redirect
        response.should redirect_to(new_profile_url)
      end
    end
    
    describe "on an unsuccessful profile creation when there are validation errors" do
      before(:each) do
        Profile.should_receive(:new).with(@profile_params.merge('validate_postal_code' => true)).and_return(@profile)
        @profile.should_receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(@profile))
      end
      
      it "should set flash[:non_california_postal_code] to true" do
        do_action
        flash[:non_california_postal_code].should be(true)
      end
      
      it "should redirect to ways_to_save_energy_around_the_home_url" do
        do_action
        response.should be_redirect
        response.should redirect_to(ways_to_save_energy_around_the_home_url)
      end
    end
    
    def do_action
      post 'create', { 'profile' => @profile_params }
    end
  end
  
  describe "#update on PUT" do
    before(:each) do
      @profile_params = { 'postal_code' => '94044' }
    end
    
    it_should_behave_like "a controller that recalls a remembered profile or redirects to new_profile_url"
    
    describe "on a successful profile update" do
      before(:each) do
        setup_remembered_profile(:null_object => true, :errors => stub("errors", :count => 0, :invalid? => false))
      end
      
      it "should update the profile from params" do
        @profile.should_receive(:update_from).with(@profile_params)
        @profile.stub!(:is_owned?)
        @profile.stub!(:getting_started?)
        do_action
      end
      
      describe "when the profile is not associated with a customer" do
        before(:each) do
          @profile.stub!(:update_from)
          @profile.should_receive(:is_owned?).and_return(false)
          @profile.stub!(:getting_started?)
        end
        
        it "should remember the profile (refreshing the expiration on the cookie)" do
          @profile.should_receive(:to_param).and_return('1')
          do_action
          response.cookies['remembered_profile_id'][0].should == '1'
        end
      end
      
      describe "when the profile is associated with a customer" do
        before(:each) do
          @profile.stub!(:update_from)
          @profile.should_receive(:is_owned?).and_return(true)
          @profile.stub!(:getting_started?)
        end
        
        it "should not remember the profile" do
          @profile.should_not_receive(:to_param)
          do_action
        end
      end
      
      describe "if the user is still getting started" do
        before(:each) do
          @profile.stub!(:update_from)
          @profile.stub!(:is_owned?).and_return(true)
          @profile.should_receive(:getting_started?).and_return(true)
        end
        
        describe "and the request is normal" do
          it "should redirect to new_profile_url" do
            do_action
            response.should be_redirect
            response.should redirect_to(new_profile_url)
          end
        end
        
        describe "and the request is xhr" do
          before(:each) do
            @last_completed_field = 'postal_code'
            @profile.should_receive(:last_completed_getting_started_field).and_return(@last_completed_field)
            @next_field = 'utility'
            @profile.should_receive(:next_getting_started_fields).and_return([@next_field])
          end
          
          it "should replace the last completed field (to grey it out)" do
            do_xhr_action
            response.should have_rjs(:replace, @last_completed_field, :partial => "profiles/learn/get_started_#{@last_completed_field}", :locals => { :profile => @profile })
          end
          
          it "should insert each of the next fields, initially hidden" do
            do_xhr_action
            response.should have_rjs(:insert_html, 'get_started_fields', :partial => "profiles/learn/get_started_#{@next_field}", :locals => { :profile => @profile, :initially_hidden => true })
          end
          
          # punting the visual stuff (since it would require some hairy regexps)
          it "should fade in each of the next fields" do
            do_xhr_action
          end
          
          it "should scroll to and focus each of the next fields after a short delay" do
            do_xhr_action
          end
        end
      end
      
      describe "if the user is not getting started" do
        before(:each) do
          @profile.stub!(:update_from)
          @profile.stub!(:is_owned?).and_return(true)
          @profile.should_receive(:getting_started?).and_return(false)
        end
        
        describe "and the request is normal" do
          describe "and session[:current_tab_url] is set" do
            before(:each) do
              session[:current_tab_url] = 'http://test.host/login'
            end
            
            it "should redirect to session[:current_tab_url]" do
              do_action
              response.should be_redirect
              response.should redirect_to(login_url)
            end
          end
          
          describe "and session[:current_tab_url] is not set" do
            it "should redirect to explore_url" do
              do_action
              response.should be_redirect
              response.should redirect_to(explore_url)
            end
          end
        end
        
        describe "and the request is xhr (meaning the user is finalizing the getting started process)" do
          it "should optimize the profile's system size" do
            @profile.should_receive(:optimize_system_size!)
            do_xhr_action
          end
          
          it "should redirect to explore_url via Javascript" do
            @profile.stub!(:optimize_system_size!)
            do_xhr_action
            response.should have_text("window.location.href = \"#{explore_url}\";")
          end
        end
      end
    end
    
    describe "on an unsuccessful profile update with validation errors" do
      before(:each) do
        setup_remembered_profile
        @profile.errors.stub!(:full_messages).and_return([])
        @profile.errors.stub!(:invalid?)
        @profile.stub!(:update_from).and_raise(ActiveRecord::RecordInvalid.new(@profile))
      end
      
      describe "if the user is still getting started" do
        before(:each) do
          @profile.should_receive(:getting_started?).and_return(true)
        end
        
        describe "and the request is normal" do
          it "should respond :success" do
            do_action
            response.should be_success
          end

          it_should_behave_like "a controller performing a 'learn' action"

          it "should set @tab to 'get_started'" do
            do_action
            assigns[:tab].should == 'get_started'
          end

          it "should set session[:current_tab_url] to new_profile_url" do
            do_action
            session[:current_tab_url].should == new_profile_url
          end

          it "should set @view_title to 'Get Started'" do
            do_action
            assigns[:view_title].should == 'Get Started'
          end
          
          it "should set flash[:warning] to 'Please review and correct the errors below.'" do
            do_action
            flash[:warning].should == 'Please review and correct the errors below.'
          end
          
          it "should render :action => 'new'" do
            controller.expect_render(:action => 'new')
            do_action
          end
        end
        
        describe "and the request is xhr" do
          before(:each) do
            @current_field = 'postal_code'
            @profile.should_receive(:current_getting_started_field).and_return(@current_field)
          end
          
          it "should replace the current field with another indicating the error" do
            do_xhr_action
            response.should have_rjs(:replace, @current_field, :partial => "profiles/learn/get_started_#{@current_field}", :locals => { :profile => @profile })
          end
          
          # it "should scroll to the invalid field" do
          #   do_xhr_action
          #   # punting
          # end
        end
      end
      
      describe "if the user is not getting started" do
        before(:each) do
          @profile.should_receive(:getting_started?).and_return(false)
        end
        
        describe "and session[:current_tab_url] is set" do
          describe "to profile_financial_overview_url" do
            before(:each) do
              session[:current_tab_url] = 'http://test.host/explore/financial'
            end
          
            it "should respond :success" do
              do_action
              response.should be_success
            end

            it_should_behave_like "a controller performing an 'explore' action"
          
            it "should set @tab to 'financial_overview'" do
              do_action
              assigns[:tab].should == 'financial_overview'
            end

            it "should set session[:current_tab_url] to profile_financial_overview_url" do
              do_action
              session[:current_tab_url].should == profile_financial_overview_url
            end

            it "should set @view_title to 'Financial Overview'" do
              do_action
              assigns[:view_title].should == 'Financial Overview'
            end
          
            it "should set flash[:warning] to 'Please review and correct the errors below.'" do
              do_action
              flash[:warning].should == 'Please review and correct the errors below.'
            end
          
            it "should render the appropriate tab" do
              controller.expect_render(:controller => 'content', :action => 'financial_overview')
              do_action
            end
          end
          
          describe "to profile_environmental_overview_url" do
            before(:each) do
              session[:current_tab_url] = 'http://test.host/explore/environmental'
            end
          
            it "should respond :success" do
              do_action
              response.should be_success
            end

            it_should_behave_like "a controller performing an 'explore' action"
          
            it "should set @tab to 'environmental_overview'" do
              do_action
              assigns[:tab].should == 'environmental_overview'
            end

            it "should set session[:current_tab_url] to profile_environmental_overview_url" do
              do_action
              session[:current_tab_url].should == profile_environmental_overview_url
            end

            it "should set @view_title to 'Environmental Overview'" do
              do_action
              assigns[:view_title].should == 'Environmental Overview'
            end
          
            it "should set flash[:warning] to 'Please review and correct the errors below.'" do
              do_action
              flash[:warning].should == 'Please review and correct the errors below.'
            end
          
            it "should render the appropriate tab" do
              controller.expect_render(:controller => 'content', :action => 'environmental_overview')
              do_action
            end
          end
          
          describe "to profile_system_output_and_electric_use_url" do
            before(:each) do
              session[:current_tab_url] = 'http://test.host/explore/system_output_and_electric_use'
            end
          
            it "should respond :success" do
              do_action
              response.should be_success
            end

            it_should_behave_like "a controller performing an 'explore' action"
          
            it "should set @tab to 'system_output_and_electric_use'" do
              do_action
              assigns[:tab].should == 'system_output_and_electric_use'
            end

            it "should set session[:current_tab_url] to profile_system_output_and_electric_use_url" do
              do_action
              session[:current_tab_url].should == profile_system_output_and_electric_use_url
            end

            it "should set @view_title to 'System Output & Electric Use'" do
              do_action
              assigns[:view_title].should == 'System Output & Electric Use'
            end
          
            it "should set flash[:warning] to 'Please review and correct the errors below.'" do
              do_action
              flash[:warning].should == 'Please review and correct the errors below.'
            end
          
            it "should render the appropriate tab" do
              controller.expect_render(:controller => 'content', :action => 'system_output_and_electric_use')
              do_action
            end
          end
          
          describe "to anything other than profile_financial_overview_url, profile_environmental_overview_url, or profile_system_output_and_electric_use_url" do
            before(:each) do
              session[:current_tab_url] = 'http://test.host/explore'
            end
          
            it "should respond :success" do
              do_action
              response.should be_success
            end

            it_should_behave_like "a controller performing an 'explore' action"
          
            it "should set @tab to 'profile_overview'" do
              do_action
              assigns[:tab].should == 'profile_overview'
            end

            it "should set session[:current_tab_url] to explore_url" do
              do_action
              session[:current_tab_url].should == explore_url
            end

            it "should set @view_title to 'Your Solar Overview'" do
              do_action
              assigns[:view_title].should == 'Your Solar Overview'
            end
          
            it "should set flash[:warning] to 'Please review and correct the errors below.'" do
              do_action
              flash[:warning].should == 'Please review and correct the errors below.'
            end
          
            it "should render the appropriate tab" do
              controller.expect_render(:controller => 'content', :action => 'profile_overview')
              do_action
            end
          end
        end
        
        describe "and session[:current_tab_url] is not set" do
          it "should respond :success" do
            do_action
            response.should be_success
          end

          it_should_behave_like "a controller performing an 'explore' action"

          it "should set @tab to 'profile_overview'" do
            do_action
            assigns[:tab].should == 'profile_overview'
          end

          it "should set session[:current_tab_url] to explore_url" do
            do_action
            session[:current_tab_url].should == explore_url
          end

          it "should set @view_title to 'Your Solar Overview'" do
            do_action
            assigns[:view_title].should == 'Your Solar Overview'
          end
          
          it "should set flash[:warning] to 'Please review and correct the errors below.'" do
            do_action
            flash[:warning].should == 'Please review and correct the errors below.'
          end
          
          it "should render the profile_overview tab" do
            controller.expect_render(:controller => 'content', :action => 'profile_overview')
            do_action
          end
        end
      end
    end
    
    def stub_additional_methods_on_success
      @profile.stub!(:update_from)
      @profile.stub!(:is_owned?).and_return(true)
      @profile.stub!(:getting_started?)
    end
    
    def do_action
      put 'update', { 'profile' => @profile_params }
    end
    
    def do_xhr_action
      xhr :put, 'update', { 'profile' => @profile_params }
    end
  end
end
