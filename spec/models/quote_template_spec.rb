require File.dirname(__FILE__) + '/../spec_helper'

describe QuoteTemplate do
  before(:each) do
    @template = QuoteTemplate.new
  end
  
  #
  # Apply to
  #
  
  describe "when told to apply itself to a Quote" do
    before(:each) do
      @quote = mock_model(Quote)
      @photovoltaic_module = mock('photovoltaic_module')
      @number_of_modules = mock('number_of_modules')
      @photovoltaic_inverter = mock('photovoltaic_inverter')
      @number_of_inverters = mock('number_of_inverters')
      @system_price = mock('system_price')
      @installation_available = mock('installation_available')
      @installation_estimate = mock('installation_estimate')
      @will_accept_rebate_assignment = mock('will_accept_rebate_assignment')
      @company_backgrounder = mock_model(CompanyBackgrounder)
    end
    
    it "should set all of the quote's settings to match the template" do
      @template.should_receive(:photovoltaic_module).and_return(@photovoltaic_module)
      @quote.should_receive(:photovoltaic_module=).with(@photovoltaic_module)
      
      @template.should_receive(:number_of_modules).and_return(@number_of_modules)
      @quote.should_receive(:number_of_modules=).with(@number_of_modules)
      
      @template.should_receive(:photovoltaic_inverter).and_return(@photovoltaic_inverter)
      @quote.should_receive(:photovoltaic_inverter=).with(@photovoltaic_inverter)
      
      @template.should_receive(:number_of_inverters).and_return(@number_of_inverters)
      @quote.should_receive(:number_of_inverters=).with(@number_of_inverters)
      
      @template.should_receive(:system_price).and_return(@system_price)
      @quote.should_receive(:system_price=).with(@system_price)
      
      @template.should_receive(:installation_available).and_return(@installation_available)
      @quote.should_receive(:installation_available=).with(@installation_available)
      
      @template.should_receive(:installation_estimate).and_return(@installation_estimate)
      @quote.should_receive(:installation_estimate=).with(@installation_estimate)
      
      @template.should_receive(:will_accept_rebate_assignment).and_return(@will_accept_rebate_assignment)
      @quote.should_receive(:will_accept_rebate_assignment=).with(@will_accept_rebate_assignment)
      
      @template.should_receive(:company_backgrounder).and_return(@company_backgrounder)
      @quote.should_receive(:company_backgrounder=).with(@company_backgrounder)
      
      @quote.should_receive(:set_manufacturers)
      
      @template.apply_to(@quote)
    end
  end
  
  [ :partner_id, :photovoltaic_module_id, :number_of_modules, :photovoltaic_inverter_id, :description, :number_of_inverters, :system_price, :installation_estimate ].each do |attribute| 
  	it "should allow #{attribute} to be changed via mass-assignment" do
  	  @template.send(attribute).should be_blank
  	  @template.attributes = { attribute.to_sym => 1 }
  	  @template.send(attribute).should == 1
  	end
	end

	[ :installation_available, :will_accept_rebate_assignment ].each do |attribute| 
  	it "should allow #{attribute} to be changed via mass-assignment" do
  	  @template.attributes = { attribute.to_sym => true }
  	  @template.send(attribute).should == true
  	end
	end

	[ :created_at, :updated_at ].each do |attribute| 
  	it "should not allow #{attribute} to be changed via mass-assignment" do
    	@template.send(attribute).should be_blank
    	@template.attributes = { attribute.to_sym => 10 }
    	@template.send(attribute).should be_blank
  	end
	end
  
  
  #
  # Sizing
  #
  
  [ :nameplate_rating, :cec_rating ].each do |m|
    it "should delegate #{m} to :calculation_engine" do
      stub_calculation_engine
      @engine.should_receive(m)
      @template.send(m)
    end
  end
  
  
  #
  # System cost
  #
  
  [ :system_cost, :installation_cost ].each do |m|
    it "should delegate #{m} to :calculation_engine" do
      stub_calculation_engine
      @engine.should_receive(m)
      @template.send(m)
    end
  end
  
  
  #
  # Annual output
  #
  
  [ :annual_output ].each do |m|
    it "should delegate #{m} to :calculation_engine" do
      stub_calculation_engine
      @engine.should_receive(m)
      @template.send(m)
    end
  end
  
  
  #
  # Miscellaneous readers
  #
  
  describe "#module_type" do
    before(:each) do
      @module = mock_model(PhotovoltaicModule)
      @module.should_receive(:model_and_description).and_return('module')
      @template.should_receive(:photovoltaic_module).and_return(@module)
    end
    
    it "should return the :model_and_description of the :photovoltaic_module" do
      @template.module_type.should == 'module'
    end
  end
  
  describe "#inverter_type" do
    before(:each) do
      @inverter = mock_model(PhotovoltaicInverter)
      @inverter.should_receive(:model_and_description).and_return('inverter')
      @template.should_receive(:photovoltaic_inverter).and_return(@inverter)
    end
    
    it "should return the :model_and_description of the :photovoltaic_inverter" do
      @template.inverter_type.should == 'inverter'
    end
  end
  
  [ :stc_rating, :ptc_rating ].each do |m|
    describe "#module_#{m}" do
      describe "when photovoltaic_module is blank" do
        it "should return 0.0" do
          @template.send("module_#{m}").should == 0.0
        end
      end
    
      describe "when photovoltaic_module is not blank" do
        before(:each) do
          @module = mock_model(PhotovoltaicModule)
          @module.should_receive(m).and_return(1.0)
          @template.should_receive(:photovoltaic_module).twice.and_return(@module)
        end
      
        it "should return the #{m} of the module" do
          @template.send("module_#{m}").should == 1.0
        end
      end
    end
  end
  
  describe "#module_count" do
    describe "when :number_of_modules is blank" do
      it "should return 0.0" do
        @template.module_count.should == 0.0
      end
    end
  
    describe "when :number_of_modules is not blank" do
      before(:each) do
        @template.number_of_modules = 15
      end
    
      it "should return the number of modules" do
        @template.module_count.should == 15
      end
    end
  end
  
  describe "#inverter_weighted_efficiency" do
    describe "when photovoltaic_inverter is blank" do
      it "should return 93%" do
        @template.inverter_weighted_efficiency.should == 93.percent
      end
    end
  
    describe "when photovoltaic_inverter is not blank" do
      before(:each) do
        @inverter = mock_model(PhotovoltaicInverter)
        @inverter.should_receive(:weighted_efficiency).and_return(94.percent)
        @template.should_receive(:photovoltaic_inverter).twice.and_return(@inverter)
      end
    
      it "should return the :weighted_efficiency of the inverter" do
        @template.inverter_weighted_efficiency.should == 94.percent
      end
    end
  end
  
  def stub_partner
    @partner = mock_model(Partner)
    @template.stub!(:partner).and_return(@partner)
  end
  
  def stub_calculation_engine
    @engine = mock('calculation_engine')
    QuoteTemplateCalculationEngine.stub!(:new).and_return(@engine)
  end
end