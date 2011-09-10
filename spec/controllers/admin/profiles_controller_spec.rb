require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../shared/login_stubs'
require File.dirname(__FILE__) + '/../shared/ssl'
require File.dirname(__FILE__) + '/shared/shared_admin_examples'

describe Admin::ProfilesController do
  include LoginStubs
  include SSL

  before(:each) do
    require_ssl
    @profile = mock_model(Profile)
  end 

  describe "#index on GET" do
    it_should_behave_like "an admin controller"
    
    describe "when user is an admin" do
      before(:each) do
        setup_valid_login_credentials_for(Administrator)
        
        @profiles = mock('profiles')
        Profile.should_receive(:paginate).with(:per_page => 20, :page => params[:page]).and_return(@profiles)
        
        do_action
      end
      
      it "should find all profiles and assign them to @profiles" do
        assigns[:profiles].should be(@profiles)
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

      it "should find the profile to show and assign it to @profile" do
        assigns[:profile].should be(@profile)
      end
    end
	  
    def do_action
      get 'show', { :id => @profile_id }
    end
  end

  describe "#edit on GET" do	  
    it_should_behave_like "an admin controller"
	  
    describe "when user is an admin" do
      before(:each) do
       	setup_valid_login_credentials_for(Administrator)
       	Profile.should_receive(:find).and_return(@profile)
       	do_action
      end

      it "should respond :success" do
        response.should be_success
      end

      it "should find the profile to edit and assign it to @profile" do
        assigns[:profile].should be(@profile)
      end
    end
		
    def do_action
      get 'edit', { :id => @profile_id }
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
          stub_profile_find
          @profile_params = { 'id' => @profile_id }
        end

        describe "on a successful update" do
          before(:each) do
            @profile.should_receive(:update_from)
          end

          it "should set flash[:notice] to 'Profile updated.'" do
            do_action
            flash[:notice].should == 'Profile updated.'
          end

          it "should respond with a redirect" do
            do_action
            response.should be_redirect
            response.should redirect_to(admin_profiles_url)
          end

          describe "when :approved is true" do
            it "should mark profile as approved" do
              @profile.should_receive(:approve!)
              @profile_params[:approved] = 'true'
              do_action
            end
          end

          describe "when :approved is false" do
            it "should mark profile as declined" do
              @profile.should_receive(:decline!)
              @profile_params[:approved] = 'false'
              do_action
            end
          end
        end

        describe "when there are validation errors" do
          before(:each) do
            @profile.errors.stub!(:full_messages).and_return([])
            @profile.should_receive(:update_from).with(@profile_params).and_raise(ActiveRecord::RecordInvalid.new(@profile))
          end
  		    
          it "should render 'edit'" do
            controller.expect_render(:action => 'edit')
            do_action
          end
        end
      end

      describe "when request is xhr" do
        before(:each) do
          @profile = stub_model(Profile)
        end

        it "should approve profile when 'approve' is selected" do
          @profile_params = { :id => '1', :profile => { :waiting_approval => 'approve' } }
          Profile.should_receive(:find).with(@profile_params[:id]).and_return(@profile)
          @profile.should_receive(:approve!)
          xhr :post, 'update', @profile_params
        end

        it "should decline profile when 'decline' is selected" do
          @profile_params = { :id => '1', :profile => { :waiting_approval => 'decline' } }
          Profile.should_receive(:find).with(@profile_params[:id]).and_return(@profile)
          @profile.should_receive(:decline!)
          xhr :post, 'update', @profile_params
        end
      end
    end
	  
    def do_action
      post 'update', { :id => @profile_id, 'profile' => @profile_params }
    end
	  
    def setup_shared_stubs
      stub_profile_find
      @profile_params = { 'id' => @profile_id }
      @profile.should_receive(:update_from).with(@profile_params)
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

      it "should set flash[:notice] to 'The RFQ has been withdrawn.'" do
        flash[:notice].should == 'The RFQ has been withdrawn.'
      end

      it "should respond with a redirect" do
        response.should be_redirect
        response.should redirect_to(admin_profiles_url)
      end
    end
		
    def do_action
      delete 'destroy', { :id => @profile_id }
    end
		
    def setup_shared_stubs
      stub_profile_find
      @profile.should_receive(:withdraw!)
    end
  end
	
  def stub_profile_find
    @profile_id = '1'
    Profile.should_receive(:find).with(@profile_id).and_return(@profile)
  end
  
  def setup_shared_stubs
    stub_profile_find
  end
end
