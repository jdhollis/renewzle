require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../shared/login_stubs'
require File.dirname(__FILE__) + '/../shared/ssl'
require File.dirname(__FILE__) + '/shared/shared_partner_examples'

describe Retailer::PartnersController do
	include LoginStubs
	include SSL

	before(:each) do
		@partner = stub_model(Partner)
	end

  describe "#create on POST" do
    before(:each) do
      require_ssl
      setup_valid_login_credentials_for(Partner)
      @company = stub_model(Company)
      @partner.should_receive(:company=)
      Company.stub!(:find).with(@company.id.to_s).and_return(@company)
      Partner.stub!(:new).and_return(@partner)
      @partner_params = {}
    end

    describe "when request is xhr?" do
      describe "on successful post" do
        before(:each) do
          @partner.should_receive(:save!)
          @partner.should_receive(:approve!)
          do_xhr_action
        end

        it "should remove new_partner_fields" do
          response.should have_rjs(:remove, 'new_partner_fields')
        end

        it "should update partners" do
          response.should have_rjs(:insert_html, :bottom, 'partners')
        end
      end

      describe "on invalid record" do
        before(:each) do
          @partner.errors.stub!(:full_messages).and_return([])
          @partner.should_receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(@partner))
          do_xhr_action
        end

        it "should update partner_fields" do
          response.should have_rjs(:replace_html, 'new_partner_fields')
        end
      end
    end

    def do_xhr_action
      xhr :put, 'create', { :company_id => @company.id, :partner => @partner_params }
    end
  end
	
  describe "#edit on GET" do
    before(:each) do
      require_ssl
    end

    it_should_behave_like "a retailer controller"

    describe "when user is a partner" do
      before(:each) do
				@partner = mock_model(Partner)
        setup_valid_login_credentials_for(Partner)
      end

			it "should respond :success" do
				do_action
				response.should be_success
			end
			
			it "should set @location to 'account'" do
				do_action
				assigns[:location].should == 'account'
			end
			
			it "should set @view_title to 'My Account'" do
				do_action
				assigns[:view_title].should == 'My Account'
			end
    end
		
		def do_action
		  get 'edit'
		end
  end

	describe "#update on POST" do
    before(:each) do
      require_ssl
    end

	  it_should_behave_like "a retailer controller"
	  
	  describe "when user is a partner" do
      before(:each) do
				@partner = stub_model(Partner)
       	setup_valid_login_credentials_for(Partner)
  		end

      describe "when request is normal" do
  		  describe "on a successful update" do
  		  	before(:each) do
			  		#setup_shared_stubs
  		  		@user.should_receive(:update_from).with(@partner_params)
  		  		do_action
  		  	end

  		  	it "should set flash[:notice] to 'Your account has been updated.'" do
  		  		flash[:notice].should == 'Your account has been updated.'
  		  	end

  		  	it "should respond with a redirect" do
  		  		response.should be_redirect
  		  		response.should redirect_to(retailer_dashboard_url)
  		  	end
  		  end

  		  describe "when there are validation errors" do
  		    before(:each) do
  		      @user.errors.stub!(:full_messages).and_return([])
            @user.should_receive(:update_from).with(@partner_params).and_raise(ActiveRecord::RecordInvalid.new(@user))
  		    end
  		    
  		  	it "should render 'edit'" do
            controller.expect_render(:action => 'edit')
  		  		do_action
  		  	end
  		  end
      end

      describe "when request is xhr?" do
        before(:each) do
          @partner_params = {}
          Partner.should_receive(:find).with(@partner.id).and_return(@partner)
        end

        describe "on a successful update" do
          before(:each) do
            @partner.should_receive(:update_from)
            do_xhr_action
          end
        
          it "should update partner div" do
            response.should have_rjs(:replace_html)
          end
        end

        describe "when there are validation errors" do
          before(:each) do
  		      @partner.errors.stub!(:full_messages).and_return([])
            @partner.should_receive(:update_from).and_raise(ActiveRecord::RecordInvalid.new(@partner))
            do_xhr_action
          end

          it "should replace partner html" do
            response.should have_rjs(:replace_html)
          end
        end
      end
	  end

    def do_xhr_action
      xhr :post, 'update', { :partners => { @partner.id =>  @partner_params }}
    end
	  
	  def do_action
	    post 'update', { 'partner' => @partner_params }
	  end
	end

	describe "#destroy on GET" do
    before(:each) do
      require_ssl
    end

	  describe "when user is a partner" do
      before(:each) do
       	setup_valid_login_credentials_for(Partner)
				@user.should_receive(:destroy)
				do_action
			end

			it "should logout user" do
				cookies['login_token_value'].should be_nil
			end

			it "should set flash[:notice] to 'Your account has been deleted.'" do
				flash[:notice].should == 'Your account has been deleted.'
			end

			it "should redirect_to login_url" do
				response.should be_redirect
				response.should redirect_to(login_url)
			end
		end

		def do_action
			get 'destroy', { 'id' => @user.id }
		end
	end

	def stub_partner_finder
		Partner.should_receive(:find).with(@user.id).and_return(@partner)
	end

  def setup_shared_stubs
		@partner_id = 1
    @partner_params = { 'id' => @partner_id }
		stub_partner_finder
  end
end
