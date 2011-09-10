require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../shared/login_stubs'
require File.dirname(__FILE__) + '/../shared/ssl'
require File.dirname(__FILE__) + '/shared/shared_partner_examples'

describe Retailer::QuotesController do
  include LoginStubs
  include SSL

  before(:each) do
    @quote = stub_model(Quote)
  end 

  describe "#index on GET" do
    it_should_behave_like "a retailer controller"
    
    describe "when user is a partner" do
      before(:each) do
        setup_valid_login_credentials_for(Partner)
        setup_shared_stubs
      end

      it "should respond :success" do
        do_action
        response.should be_success
      end
			
      it "should set @location to 'quotes'" do
        do_action
        assigns[:location].should == 'quotes'
      end
			
      it "should set @view_title to 'My Quotes'" do
        do_action
        assigns[:view_title].should == 'My Quotes'
      end
    end
		
    def do_action
      get 'index'
    end
  end
  
  describe "#show on GET" do
    before(:each) do
      require_ssl
    end

    it_should_behave_like "a retailer controller"
	  
    describe "when user is a partner" do
      before(:each) do
       	setup_valid_login_credentials_for(Partner)
       	setup_shared_stubs
        do_action
      end

      it "should respond :success" do
        response.should be_success
      end

      it "should set @location to 'quotes'" do
        assigns[:location].should == 'quotes'
      end
			
      it "should set @view_title to 'Quote for 'Peter Griffin''" do
        assigns[:view_title].should == "Quote for 'Peter Griffin'"
      end

      it "should find the quote to show and assign it to @quote" do
        assigns[:quote].should be(@quote)
      end
    end
	  
    def do_action
      get 'show', { :id => @quote_id }
    end
  end

  describe "#new on GET" do
    before(:each) do
      require_ssl
    end

    it_should_behave_like "a retailer controller"
	  
    describe "when user is a partner" do
      before(:each) do
       	setup_valid_login_credentials_for(Partner)
       	setup_shared_stubs
        do_action
      end

      it "should respond :success" do
        response.should be_success
      end

      it "should set @location to 'quotes'" do
        assigns[:location].should == 'quotes'
      end
			
			it "should set @view_title to 'Make a Quote'" do
				assigns[:view_title].should == 'Make a Quote'
			end

  		it "should find the profile to show and assign it to @profile" do
  			assigns[:profile].should be(@profile)
  		end
  		
  		it "should set @quote_templates to the user's quote templates" do
  		  assigns[:quote_templates].should be(@quote_templates)
  		end
	  end
	  
	  def do_action
	    get 'new', { :profile_id => @profile_id }
	  end

		def stub_profile_find
			@profile = mock_model(Profile)
			Profile.stub!(:find).with(@profile_id).and_return(@profile)
		end

		def setup_shared_stubs
			stub_profile_find
      stub_user_company_backgrounders
			@quote_templates = mock('quote templates')
			@company.should_receive(:quote_templates).and_return(@quote_templates)
		end
	end

  describe "#create on POST" do
    before(:each) do
      require_ssl
    end

    it_should_behave_like "a retailer controller"
	  
    describe "when user is a partner" do
      describe "when request is normal" do
      	before(:each) do
          setup_valid_login_credentials_for(Partner)
          setup_shared_stubs
      	  @quote_params = { 'id' => @quote_id }
        end

        describe "on a successful update" do
          before(:each) do
            Quote.should_receive(:new).with(@quote_params.merge('partner' => @user)).and_return(@quote)
            @quote.should_receive(:save!)
            do_action
          end

          it "should set flash[:notice] to 'Quote submitted.'" do
            flash[:notice].should == 'Quote submitted.'
          end

          it "should respond with a redirect" do
            response.should be_redirect
            response.should redirect_to(retailer_dashboard_url)
          end
        end

        describe "when there are validation errors" do
          before(:each) do
            Quote.should_receive(:new).with(@quote_params.merge('partner' => @user)).and_return(@quote)
            @quote.errors.stub!(:full_messages).and_return([])
      	    @quote.should_receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(@quote))
      	    
      			@quote_templates = mock('quote templates')
      			@company.should_receive(:quote_templates).and_return(@quote_templates)
  			  end
  			  
  			  it "should set @quote_templates to the user's quote templates" do
  			    do_action
      		  assigns[:quote_templates].should be(@quote_templates)
      		end
  			  
          it "should render 'edit'" do
      	    controller.expect_render(:action => 'new')
            do_action
          end
        end
      end

      describe "when request is xhr?" do
        before(:each) do
          setup_valid_login_credentials_for(Partner)
          setup_shared_stubs
          @quote_params = { 'id' => @quote_id, 'photovoltaic_module_manufacturer' => 1, 'photovoltaic_inverter_manufacturer' => 1 }
          @quote.stub!(:profile).and_return(mock_model(Profile, :city => ''))
          @quote.stub!(:project_cost)
          @quote.stub!(:cash_outlay)
          @quote.stub!(:average_monthly_savings)
          @quote.stub!(:lifetime_savings)
          @quote.stub!(:increase_in_home_value)
          @quote.stub!(:annual_output)
          @quote.stub!(:nameplate_rating)
          @quote.stub!(:cec_rating)
          @quote.stub!(:module_type)
          @quote.stub!(:number_of_modules)
          @quote.stub!(:inverter_type)
          @quote.stub!(:number_of_inverters)
          @quote.stub!(:system_price)
          @quote.stub!(:installation_estimate)
          @quote.stub!(:total_price)
          @quote.stub!(:photovoltaic_module_id)
          @quote.stub!(:photovoltaic_inverter_id)
          Quote.should_receive(:new).with(@quote_params.merge('partner' => @user)).and_return(@quote)
        end

        it "should update #quote when updating quote" do
          xhr :post, 'create', { 'update' => 'quote', 'quote' => @quote_params }
          response.should have_rjs(:replace_html, 'quote', :partial => 'retailer/quotes/quote', :locals => { :quote => @quote })
        end

        it "should update #modules when selecting a module manufacturer" do
          # Had to use a real object as to not mock the whole ruby base
          @modules = Array.new
          PhotovoltaicModule.should_receive(:find_all_by_manufacturer).with(@quote_params['photovoltaic_module_manufacturer']).and_return(@modules)
          xhr :post, 'create', { 'update' => 'modules', 'quote' => @quote_params }
          response.should have_rjs(:replace_html, 'photovoltaic_module_fields', :partial => 'retailer/quotes/modules', :locals => { :quote => @quote, :modules => @modules })
        end

        it "should update #inverters when selecting a inverter manufacturer" do
          # Had to use a real object as to not mock the whole ruby base
          @inverters = Array.new
          PhotovoltaicInverter.should_receive(:find_all_by_manufacturer).with(@quote_params['photovoltaic_inverter_manufacturer']).and_return(@inverters)
          xhr :post, 'create', { 'update' => 'inverters', 'quote' => @quote_params }
          response.should have_rjs(:replace_html, 'photovoltaic_inverter_fields', :partial => 'retailer/quotes/inverters', :locals => { :quote => @quote, :inverters => @inverters })
        end
      end
    end
	  
    def do_action
      post 'create', { 'quote' => @quote_params }
    end
  end

  describe "#destroy on GET" do
    it_should_behave_like "a retailer controller"

    describe "when user is partner" do
      before(:each) do
        setup_valid_login_credentials_for(Partner)
  			setup_shared_stubs
				stub_quote_find
				@quote.should_receive(:destroy)
      end

			describe "when request is normal" do
    	  before(:each) do
					do_action
    	  end

				it "should set flash[:notice] to 'Your quote has been withdrawn.'" do
					flash[:notice].should == 'Your quote has been withdrawn.'
				end

				it "should respond with a redirect to retailer_dashboard_url" do
					response.should be_redirect
					response.should redirect_to(retailer_dashboard_url)
				end
			end

    	describe "when request is xhr?" do
    	  before(:each) do
					do_xhr_action
    	  end

				it "should respond :success" do
					response.should be_success
				end

				it "should update #messages" do
					self.stub!(:content_tag).and_return('')
					response.should have_rjs(:replace_html, 'messages', content_tag('p', 'Your quote has been withdrawn.', :class => 'notice'))
				end

				def do_xhr_action
					xhr :get, 'destroy', { :id => @quote_id }
				end
    	end
		end

		def do_action
		  get 'destroy', { :id => @quote_id }
		end
	end

	def stub_quote_find
    @quote_id = '1'
		@quote.stub!(:customer).and_return(mock_model(User, :full_name => 'Peter Griffin'))
		@quotes.stub!(:find).with(@quote_id).and_return(@quote)
  end
  
  def setup_shared_stubs
    @quotes = mock('quotes', :paginate => [])
    @user.stub!(:quotes).and_return(@quotes)
    stub_quote_find
    stub_user_company_backgrounders
  end
  
  def stub_user_company_backgrounders
    @company = mock_model(Company)
    @user.stub!(:company).and_return(@company)
    @company_backgrounders = mock('company_backgrounders')
    @company.stub!(:company_backgrounders).and_return(@company_backgrounders)
    @company_backgrounders.stub!(:available)
  end
end
