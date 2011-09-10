require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/shared/login_stubs'
require File.dirname(__FILE__) + '/shared/profile_stubs'
require File.dirname(__FILE__) + '/shared/shared_customer_examples'
require File.dirname(__FILE__) + '/shared/shared_content_examples'

describe ContentController do
  include LoginStubs
  include ProfileStubs

	describe "#default on GET" do
		it "should respond with a redirect" do
			get 'default'
			response.should be_redirect
		end
	end
  
  describe "#get_started on GET" do
    it "should respond :success" do
      do_action
      response.should be_success
    end
    
    it_should_behave_like "a controller performing a 'learn' action"
    
    it "should set @tab to 'get_started'" do
      do_action
      assigns[:tab].should == 'get_started'
    end
    
    it "should set session[:current_tab_url] to learn_url" do
      do_action
      session[:current_tab_url].should == learn_url
    end
    
    it "should set @view_title to 'Residential Solar Energy Made Easy'" do
      do_action
      assigns[:view_title].should == 'Residential Solar Energy Made Easy'
    end
    
    it "should set @meta_description to 'Do you want to install solar panels for your home? Renewzle answers these questions: What is the right solar power system size? How much does solar save in energy costs? How can you get the best price from the best solar system retailers and installers  With information and a calculator for residential solar energy systems, Renewzle makes solar power easy.'" do
      do_action
      assigns[:meta_description].should == 'Do you want to install solar panels for your home? Renewzle answers these questions: What is the right solar power system size? How much does solar save in energy costs? How can you get the best price from the best solar system retailers and installers  With information and a calculator for residential solar energy systems, Renewzle makes solar power easy.'
    end
    
    it "should set @meta_keywords to 'solar energy, solar power, solar panels, residential solar energy systems, residential solar power, solar installer, solar power retailer, photovoltaics, photovoltaic panels, solar pv panels, solar system cost, solar system size, solar system comparison tool, solar financial analysis'" do
      do_action
      assigns[:meta_keywords].should == 'solar energy, solar power, solar panels, residential solar energy systems, residential solar power, solar installer, solar power retailer, photovoltaics, photovoltaic panels, solar pv panels, solar system cost, solar system size, solar system comparison tool, solar financial analysis'
    end
    
    it_should_behave_like "a controller that recalls a remembered profile or creates a new one"
    
    describe "when @profile is not a new record" do
      before(:each) do
        setup_remembered_profile
      end
      
      it "should render profiles/continue instead of profiles/get_started" do
        controller.expect_render(:template => 'profiles/continue')
        do_action
      end
    end
    
    def do_action
      get 'get_started'
    end
  end
  
  describe "#how_solar_systems_work on GET" do
    it "should respond :success" do
      do_action
      response.should be_success
    end
    
    it_should_behave_like "a controller performing a 'learn' action"
    
    it "should set @tab to 'get_started'" do
      do_action
      assigns[:tab].should == 'how_solar_systems_work'
    end
    
    it "should set session[:current_tab_url] to how_solar_systems_work_url" do
      do_action
      session[:current_tab_url].should == how_solar_systems_work_url
    end
    
    it "should set @view_title to 'How Solar Systems Work'" do
      do_action
      assigns[:view_title].should == 'How Solar Systems Work'
    end
    
    it "should set @meta_description to 'Curious how solar panels would work in your house? Learn about all the components of a home solar system and how they function together, including information on solar modules and panels, solar inverters, electrical panels, utility meters and the utility grid.'" do
      do_action
      assigns[:meta_description].should == 'Curious how solar panels would work in your house? Learn about all the components of a home solar system and how they function together, including information on solar modules and panels, solar inverters, electrical panels, utility meters and the utility grid.'
    end
    
    it "should set @meta_keywords to 'how solar energy works, how solar panels work, solar modules, solar inverters, photovoltaic cells, photovoltaic panels, solar grid'" do
      do_action
      assigns[:meta_keywords].should == 'how solar energy works, how solar panels work, solar modules, solar inverters, photovoltaic cells, photovoltaic panels, solar grid'
    end
    
    it_should_behave_like "a controller that recalls a remembered profile or creates a new one"
    
    def do_action
      get 'how_solar_systems_work'
    end
  end
  
  describe "#solar_power_costs_savings on GET" do
    it "should respond :success" do
      do_action
      response.should be_success
    end
    
    it_should_behave_like "a controller performing a 'learn' action"
    
    it "should set @tab to 'get_started'" do
      do_action
      assigns[:tab].should == 'solar_power_costs_savings'
    end
    
    it "should set session[:current_tab_url] to solar_power_costs_savings_url" do
      do_action
      session[:current_tab_url].should == solar_power_costs_savings_url
    end
    
    it "should set @view_title to 'Solar Power Costs & Savings'" do
      do_action
      assigns[:view_title].should == 'Solar Power Costs & Savings'
    end
    
    it "should set @meta_description to 'Are solar panels really cost effective? Renewzle identifies the elements of the cost of solar power and helps you estimate the approximate cost to install solar panels in your home. What are your potential cost savings from solar energy?'" do
      do_action
      assigns[:meta_description].should == 'Are solar panels really cost effective? Renewzle identifies the elements of the cost of solar power and helps you estimate the approximate cost to install solar panels in your home. What are your potential cost savings from solar energy?'
    end
    
    it "should set @meta_keywords to 'solar enery cost, solar panel cost, cost to install solar panels, solar power cost, is solar power cost efficient, how much do solar panels cost, solar cost savings, solar panel price, solar power financial factors'" do
      do_action
      assigns[:meta_keywords].should == 'solar enery cost, solar panel cost, cost to install solar panels, solar power cost, is solar power cost efficient, how much do solar panels cost, solar cost savings, solar panel price, solar power financial factors'
    end
    
    it_should_behave_like "a controller that recalls a remembered profile or creates a new one"
    
    def do_action
      get 'solar_power_costs_savings'
    end
  end
  
  describe "#solar_and_the_environment on GET" do
    it "should respond :success" do
      do_action
      response.should be_success
    end
    
    it_should_behave_like "a controller performing a 'learn' action"
    
    it "should set @tab to 'get_started'" do
      do_action
      assigns[:tab].should == 'solar_and_the_environment'
    end
    
    it "should set session[:current_tab_url] to solar_and_the_environment_url" do
      do_action
      session[:current_tab_url].should == solar_and_the_environment_url
    end
    
    it "should set @view_title to 'Solar Energy & the Environment'" do
      do_action
      assigns[:view_title].should == 'Solar Energy & the Environment'
    end
    
    it "should set @meta_description to 'How does switching to solar power help the environment? Get information here on how solar energy compares to fossil fuels in terms of toxic pollutants, emissions and consumption of non-renewable resources.'" do
      do_action
      assigns[:meta_description].should == 'How does switching to solar power help the environment? Get information here on how solar energy compares to fossil fuels in terms of toxic pollutants, emissions and consumption of non-renewable resources.'
    end
    
    it "should set @meta_keywords to 'facts about solar energy, how clean is solar energy, solar energy vs fossil fuels, reducing carbon dioxide, nitrogen oxide, sulphur dioxide, particulates, reducing air pollutants, conserve fossil fuels, solar power and environment'" do
      do_action
      assigns[:meta_keywords].should == 'facts about solar energy, how clean is solar energy, solar energy vs fossil fuels, reducing carbon dioxide, nitrogen oxide, sulphur dioxide, particulates, reducing air pollutants, conserve fossil fuels, solar power and environment'
    end
    
    it_should_behave_like "a controller that recalls a remembered profile or creates a new one"
    
    def do_action
      get 'solar_and_the_environment'
    end
  end
  
  describe "#rebates_and_incentives on GET" do
    it "should respond :success" do
      do_action
      response.should be_success
    end
    
    it_should_behave_like "a controller performing a 'learn' action"
    
    it "should set @tab to 'get_started'" do
      do_action
      assigns[:tab].should == 'rebates_and_incentives'
    end
    
    it "should set session[:current_tab_url] to rebates_and_incentives_url" do
      do_action
      session[:current_tab_url].should == rebates_and_incentives_url
    end
    
    it "should set @view_title to 'Solar Rebates & Financial Incentives'" do
      do_action
      assigns[:view_title].should == 'Solar Rebates & Financial Incentives'
    end
    
    it "should set @meta_description to 'Find information on federal, state and utility rebates and incentives that apply when you install a residential solar power system. Incentives can come in the form of tax credits or rebates from utilities, and can often cover a substantial portion of the total cost of installing a solar system for your home.'" do
      do_action
      assigns[:meta_description].should == 'Find information on federal, state and utility rebates and incentives that apply when you install a residential solar power system. Incentives can come in the form of tax credits or rebates from utilities, and can often cover a substantial portion of the total cost of installing a solar system for your home.'
    end
    
    it "should set @meta_keywords to 'solar tax credit, solar panel tax credit, solar energy tax credit, federal solar tax credit, solar rebate, solar electricity tax refund, solar energy tax incentive, solar energy rebate, solar panel rebate, federal solar incentives, photovoltaic incentives, solar photovoltaic grant'" do
      do_action
      assigns[:meta_keywords].should == 'solar tax credit, solar panel tax credit, solar energy tax credit, federal solar tax credit, solar rebate, solar electricity tax refund, solar energy tax incentive, solar energy rebate, solar panel rebate, federal solar incentives, photovoltaic incentives, solar photovoltaic grant'
    end
    
    it_should_behave_like "a controller that recalls a remembered profile or creates a new one"
    
    def do_action
      get 'rebates_and_incentives'
    end
  end
  
  describe "#profile_overview on GET" do
    it_should_behave_like "a controller that recalls a remembered profile or redirects to new_profile_url"
    
    describe "when there is a remembered profile" do
      before(:each) do
        setup_remembered_profile
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
    end
    
    def stub_additional_methods_on_success
    end
    
    def do_action
      get 'profile_overview'
    end
  end

	[ 'cost_offset_chart_data', 'annual_cost_chart_data', 'cumulative_annual_savings_chart_data', 'utility_source_mix_chart_data' ].each do |action|
		describe "##{action}" do
			it "should respond to xml" do
  	    setup_valid_login_credentials_for(Customer)
				@profile = stub_model(Profile)
				@user.stub!(:profile).and_return(@profile)
				format = mock('format')
				format.should_receive(:xml).and_return('xml')
				controller.should_receive(:respond_to).and_yield(format)
				get action, :format => 'xml'
				response.should be_success
			end
		end
	end
  
  describe "#financial_overview on GET" do
    it_should_behave_like "a controller that recalls a remembered profile or redirects to new_profile_url"
    
    describe "when there is a remembered profile" do
      before(:each) do
        setup_remembered_profile
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
    end
    
    def stub_additional_methods_on_success
    end
    
    def do_action
      get 'financial_overview'
    end
  end
  
  describe "#environmental_overview on GET" do
    it_should_behave_like "a controller that recalls a remembered profile or redirects to new_profile_url"
    
    describe "when there is a remembered profile" do
      before(:each) do
        setup_remembered_profile
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
    end
    
    def stub_additional_methods_on_success
    end
    
    def do_action
      get 'environmental_overview'
    end
  end
  
  describe "#system_output_and_electric_use on GET" do
    it_should_behave_like "a controller that recalls a remembered profile or redirects to new_profile_url"

    describe "when there is a remembered profile" do
      before(:each) do
        setup_remembered_profile
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
    end
    
    def stub_additional_methods_on_success
    end
    
    def do_action
      get 'system_output_and_electric_use'
    end
  end
  
  describe "#print_profile on GET" do
    it_should_behave_like "a controller that recalls a remembered profile or redirects to new_profile_url"
    
    describe "when there is a remembered profile" do
      before(:each) do
        setup_remembered_profile
      end
      
      it "should respond :success" do
        do_action
        response.should be_success
      end

      it "should set @view_title to 'Solar Financial Analysis Summary'" do
        do_action
        assigns[:view_title].should == 'Solar Financial Analysis Summary'
      end
    end
    
    def stub_additional_methods_on_success
    end
    
    def do_action
      get 'print_profile'
    end
  end
  
  describe "#request_quotes on GET" do
    describe "when the user is not logged in" do
      describe "and the user has no remembered profile" do
        it "should redirect to new_profile_url" do
          do_action
          response.should be_redirect
          response.should redirect_to(new_profile_url)
        end
      end

      describe "and the user has a valid remembered profile" do
        before(:each) do
          setup_remembered_profile
          stub_additional_methods_on_success
        end

        it "should set @profile to the remembered profile" do
          do_action
          assigns[:profile].should be(@profile)
        end
      end

      describe "and the user has an invalid remembered profile" do
        before(:each) do
          request.cookies['remembered_profile_id'] = '1'
          Profile.should_receive(:find_unowned).with('1').and_return(nil)
        end

        it "should delete the invalid remembered_profile_id cookie" do
          do_action
          response.cookies['remembered_profile_id'].should be_blank
        end

        it "should redirect to new_profile_url" do
          do_action
          response.should be_redirect
          response.should redirect_to(new_profile_url)
        end
      end
    end

    describe "when the user is logged in" do
      describe "as a customer" do
        before(:each) do
          setup_valid_login_credentials_for(Customer)
        end
        
        describe "and their profile is an RFQ" do
          before(:each) do
            @user.should_receive(:profile).and_return(@profile)
            @profile.should_receive(:rfq?).and_return(true)
          end
          
          it "should redirect to shop_url" do
            do_action
            response.should be_redirect
            response.should redirect_to(shop_url)
          end
        end
      end
      
      describe "as anything other than a customer" do
        before(:each) do
          setup_valid_login_credentials_for(User)
        end

        describe "and the user has no remembered profile" do
          it "should redirect to new_profile_url" do
            do_action
            response.should be_redirect
            response.should redirect_to(new_profile_url)
          end
        end

        describe "and the user has a valid remembered profile" do
          before(:each) do
            setup_remembered_profile
            stub_additional_methods_on_success
          end

          it "should set @profile to the remembered profile" do
            do_action
            assigns[:profile].should be(@profile)
          end
        end

        describe "and the user has an invalid remembered profile" do
          before(:each) do
            request.cookies['remembered_profile_id'] = '1'
            Profile.should_receive(:find_unowned).with('1').and_return(nil)
          end

          it "should delete the invalid remembered_profile_id cookie" do
            do_action
            response.cookies['remembered_profile_id'].should be_blank
          end

          it "should redirect to new_profile_url" do
            do_action
            response.should be_redirect
            response.should redirect_to(new_profile_url)
          end
        end
      end
    end
    
    describe "when there is a remembered profile" do
      before(:each) do
        setup_remembered_profile
        @customer = mock_model(Customer)
        Customer.should_receive(:new).and_return(@customer)
        @customer.stub!(:set_address_from)
      end
      
      it_should_behave_like "a controller performing an 'explore' action"
      
      it "should respond :success" do
        do_action
        response.should be_success
      end
      
      it "should set @customer to a new customer" do
        do_action
        assigns[:customer].should be(@customer)
      end
      
      it "should preset the @customer's address from @profile" do
        @customer.should_receive(:set_address_from).with(@profile)
        do_action
      end
      
      it "should set @view_title to 'Request Quotes'" do
        do_action
        assigns[:view_title].should == 'Request Quotes'
      end
    end
    
    def stub_additional_methods_on_success
      @customer = mock_model(Customer)
      Customer.stub!(:new).and_return(@customer)
      @customer.stub!(:set_address_from)
    end
    
    def do_action
      get 'request_quotes'
    end
  end
  
  describe "#quotes on GET" do
    it_should_behave_like "a controller performing a customer-only action"
    
    describe "when the user is logged in as a customer" do
      before(:each) do
        setup_valid_login_credentials_for(Customer)
        
        @profile = mock_model(Profile)
        @user.should_receive(:profile).and_return(@profile)

        @profile.stub!(:purchased_as_lead?)
      end
      
      #describe "and the customer has not verified their email address" do
      #  before(:each) do
      #    @user.should_receive(:verifying_email?).and_return(true)
      #  end
        
      #  it "should set flash[:notice] to 'Please verify your email address before proceeding.'" do
      #    do_action
      #    flash[:notice].should == 'Please verify your email address before proceeding.'
      #  end
        
      #  it "should redirect to explore_url" do
      #    do_action
      #    response.should be_redirect
      #    response.should redirect_to(explore_url)
      #  end
      #end
      
      #describe "and the customer has verified their email address" do
      #  before(:each) do
      #    @user.should_receive(:verifying_email?).and_return(false)
          
          
      #  end
        
        
      #end
      
      it_should_behave_like "a controller performing a 'shop' action"
      
      it "should set @profile to the user's profile" do
        do_action
        assigns[:profile].should be(@profile)
      end

      it "should delete any remembered_profile_id cookie" do
        do_action
        response.cookies['remembered_profile_id'].should be_blank
      end
      
      describe "when the profile has not been purchased as a lead" do
        before(:each) do
          @profile.should_receive(:purchased_as_lead?).and_return(false)
        end
        
        it "should set @view_title to 'My Quotes'" do
          do_action
          assigns[:view_title].should == 'My Quotes'
        end
      end
      
      describe "when the profile has been purchased as a lead" do
        before(:each) do
          @profile.should_receive(:purchased_as_lead?).and_return(true)
        end
        
        it "should set @view_title to 'My Quote'" do
          do_action
          assigns[:view_title].should == 'My Quote'
        end
      end
      
      it "should respond :success" do
        do_action
        response.should be_success
      end
    end
    
    def do_action
      get 'quotes'
    end
  end
  
  it_should_behave_like "a controller that provides access to 'About,' 'Press,' 'FAQ,' 'Privacy Policy,' and 'Terms of Service'"
end
