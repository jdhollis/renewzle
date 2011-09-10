require File.dirname(__FILE__) + '/../spec_helper'

describe Quote do
  before(:each) do
    @quote = Quote.new
  end

  it "should belong to profile" do
    @quote.should respond_to(:profile)
  end

  it "should have one lead" do
    @quote.should respond_to(:lead)
  end

  it "should have a dependent lead" do
    @lead = stub_model(Lead)
    @partner = stub_model(Partner)
    @lead.should_receive(:destroy)
    @quote.lead = @lead
    @quote.partner = @partner
    @quote.destroy
  end
  
  it "should have some specs on validations" do
    pending('write some.')
  end
  
  [ :partner_id, :profile_id, :photovoltaic_module_id, :number_of_modules, :photovoltaic_inverter_id, :number_of_inverters, :system_price, :installation_estimate ].each do |attribute| 
  	it "should allow #{attribute} to be changed via mass-assignment" do
  	  @quote.send(attribute).should be_blank
  	  @quote.attributes = { attribute.to_sym => 1 }
  	  @quote.send(attribute).should == 1
  	end
	end

	[ :installation_available, :will_accept_rebate_assignment ].each do |attribute| 
  	it "should allow #{attribute} to be changed via mass-assignment" do
  	  @quote.attributes = { attribute.to_sym => true }
  	  @quote.send(attribute).should == true
  	end
	end

	[ :created_at, :updated_at ].each do |attribute| 
  	it "should not allow #{attribute} to be changed via mass-assignment" do
    	@quote.send(attribute).should be_blank
    	@quote.attributes = { attribute.to_sym => 10 }
    	@quote.send(attribute).should be_blank
  	end
	end
	
	
	#
  # Pricing
  #
  
  describe "#lead_purchase_price" do
    before(:each) do
      @profile = mock_model(Profile)
      @quote.profile = @profile
    end

    describe "when the profile is not second_chance?" do
      before(:each) do
        @profile.should_receive(:second_chance?).and_return(false)
      end

      describe "when price is below the minimum" do
        it "should return a price" do
          @quote.should_receive(:nameplate_rating).and_return(50.0)
          @quote.lead_purchase_price.should == 100.to_money
        end
      end

      describe "when price is between the minimum and maximum" do
        it "should return a price" do
          @quote.should_receive(:nameplate_rating).and_return(5000.0)
          @quote.lead_purchase_price.should == 500.to_money
        end
      end

      describe "when price is above the maximum" do
        it "should return a price" do
          @quote.should_receive(:nameplate_rating).and_return(100000.0)
          @quote.lead_purchase_price.should == 1000.to_money
        end
      end
    end

    describe "when the profile is second_chance?" do
      before(:each) do
        @profile.should_receive(:second_chance?).and_return(true)
      end

      describe "when price is below the minimum" do
        it "should return a price" do
          @quote.should_receive(:nameplate_rating).and_return(0.0)
          @quote.lead_purchase_price.should == (100 * 50.percent).to_money
        end
      end

      describe "when price is between the minimum and maximum" do
        it "should return a price" do
          @quote.should_receive(:nameplate_rating).and_return(5000.0)
          @quote.lead_purchase_price.should == (500 * 50.percent).to_money
        end
      end

      describe "when price is above the maximum" do
        it "should return a price" do
          @quote.should_receive(:nameplate_rating).and_return(100000.0)
          @quote.lead_purchase_price.should == (1000 * 50.percent).to_money
        end
      end
    end
  end
  
  
  #
  # Sizing
  #
  
  [ :nameplate_rating, :cec_rating, :cec_rating_without_derate ].each do |m|
    it "should delegate #{m} to :calculation_engine" do
      stub_calculation_engine
      @engine.should_receive(m)
      @quote.send(m)
    end
  end
  
  
  #
  # System cost
  #
  
  [ :system_cost, :installation_cost, :project_cost, :total_price, :cash_outlay, :average_dollar_cost_per_nameplate_watt, :average_dollar_cost_per_cec_watt, :average_dollar_system_cost_per_nameplate_watt, :average_dollar_installation_cost_per_nameplate_watt, :average_dollar_installation_cost_per_nameplate_watt, :average_dollar_system_cost_per_cec_watt, :average_dollar_installation_cost_per_cec_watt ].each do |m|
    it "should delegate #{m} to :calculation_engine" do
      stub_calculation_engine
      @engine.should_receive(m)
      @quote.send(m)
    end
  end
  
  
  #
  # Annual usage, output, and bill calculations
  #
  
  [ :annual_output, :annual_usage_after, :annual_bill_after ].each do |m|
    it "should delegate #{m} to :calculation_engine" do
      stub_calculation_engine
      @engine.should_receive(m)
      @quote.send(m)
    end
  end
  
  
  #
  # Monthly usage, output, and bill calculations
  #
  
  [ :average_monthly_bill_after, :average_monthly_cost_after ].each do |m|
    it "should delegate #{m} to :calculation_engine" do
      stub_calculation_engine
      @engine.should_receive(m)
      @quote.send(m)
    end
  end
  
  
  #
  # Savings
  #
  
  [ :first_year_savings, :lifetime_savings, :average_monthly_savings ].each do |m|
    it "should delegate #{m} to :calculation_engine" do
      stub_calculation_engine
      @engine.should_receive(m)
      @quote.send(m)
    end
  end
  
  
  #
  # Loan
  #
  
  [ :monthly_loan_payment ].each do |m|
    it "should delegate #{m} to :calculation_engine" do
      stub_calculation_engine
      @engine.should_receive(m)
      @quote.send(m)
    end
  end
  
  
  #
  # Incentives
  #
  
  [ :increase_in_home_value ].each do |m|
    it "should delegate #{m} to :calculation_engine" do
      stub_calculation_engine
      @engine.should_receive(m)
      @quote.send(m)
    end
  end
  
  
  #
  # Miscellaneous readers
  #
  
  describe "#received" do
    it "should return :created_at" do
      @quote.created_at = Time.now.utc
      @quote.received.should == @quote.created_at
    end
  end
  
  describe "#module_type" do
    before(:each) do
      @module = mock_model(PhotovoltaicModule)
      @module.should_receive(:model_and_description).and_return('module')
      @quote.should_receive(:photovoltaic_module).and_return(@module)
    end
    
    it "should return the :model_and_description of the :photovoltaic_module" do
      @quote.module_type.should == 'module'
    end
  end
  
  describe "#inverter_type" do
    before(:each) do
      @inverter = mock_model(PhotovoltaicInverter)
      @inverter.should_receive(:model_and_description).and_return('inverter')
      @quote.should_receive(:photovoltaic_inverter).and_return(@inverter)
    end
    
    it "should return the :model_and_description of the :photovoltaic_inverter" do
      @quote.inverter_type.should == 'inverter'
    end
  end
  
  [ :stc_rating, :ptc_rating ].each do |m|
    describe "#module_#{m}" do
      describe "when photovoltaic_module is blank" do
        it "should return 0.0" do
          @quote.send("module_#{m}").should == 0.0
        end
      end
    
      describe "when photovoltaic_module is not blank" do
        before(:each) do
          @module = mock_model(PhotovoltaicModule)
          @module.should_receive(m).and_return(1.0)
          @quote.should_receive(:photovoltaic_module).twice.and_return(@module)
        end
      
        it "should return the #{m} of the module" do
          @quote.send("module_#{m}").should == 1.0
        end
      end
    end
  end
  
  describe "#module_count" do
    describe "when :number_of_modules is blank" do
      it "should return 0.0" do
        @quote.module_count.should == 0.0
      end
    end
  
    describe "when :number_of_modules is not blank" do
      before(:each) do
        @quote.number_of_modules = 15
      end
    
      it "should return the number of modules" do
        @quote.module_count.should == 15
      end
    end
  end
  
  describe "#inverter_weighted_efficiency" do
    describe "when photovoltaic_inverter is blank" do
      it "should return 93%" do
        @quote.inverter_weighted_efficiency.should == 93.percent
      end
    end
  
    describe "when photovoltaic_inverter is not blank" do
      before(:each) do
        @inverter = mock_model(PhotovoltaicInverter)
        @inverter.should_receive(:weighted_efficiency).and_return(94.percent)
        @quote.should_receive(:photovoltaic_inverter).twice.and_return(@inverter)
      end
    
      it "should return the :weighted_efficiency of the inverter" do
        @quote.inverter_weighted_efficiency.should == 94.percent
      end
    end
  end
  
  describe "#installer_proximity_to_customer" do
    before(:each) do
      stub_partner
      stub_customer
      @partner.should_receive(:distance_from).with(@customer).and_return(100.0)
    end
    
    it "should return the partner's distance from the customer" do
      @quote.installer_proximity_to_customer.should == 100.0
    end
  end
  
  [ :postal_code, :city, :customer ].each do |m|
    it "should delegate #{m} to :profile" do
      stub_profile
      @profile.should_receive(m)
      @quote.send(m)
    end
  end
  
  it "should delegate :total_kw_installed to :partner" do
    stub_partner
    @partner.should_receive(:total_kw_installed)
    @quote.total_kw_installed
  end
  
  
  def stub_profile
    @profile = mock_model(Profile)
    @quote.stub!(:profile).and_return(@profile)
  end
  
  def stub_partner
    @partner = mock_model(Partner)
    @quote.stub!(:partner).and_return(@partner)
  end
  
  def stub_customer
    @customer = mock_model(Customer)
    @quote.stub!(:customer).and_return(@customer)
  end
  
  def stub_calculation_engine
    @engine = mock('calculation_engine')
    QuoteCalculationEngine.stub!(:new).and_return(@engine)
  end
end