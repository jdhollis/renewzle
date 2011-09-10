require File.dirname(__FILE__) + '/../spec_helper'

describe CalculationEngine do
  #
  # Initialization
  #
  
  describe "when initialized with a profile" do
    it "should set profile and profile.utility to instance variables" do
      @profile = mock_model(Profile)
      @profile.should_receive(:utility).and_return(mock_model(Utility))
      @engine = CalculationEngine.new(@profile)
    end
  end
  
  
  #
  # Sizing
  #
  
  describe "#nameplate_rating" do
    before(:each) do
      stub_engine
      @profile.should_receive(:annual_solar_rating).and_return(4903.5)
      @profile.should_receive(:system_performance_derate).and_return(0.0)
    end
    
    describe "when provided with an output" do
      it "should return the nameplate rating in kW required to generate the provided output annually, calculated with (output / 1.89 * (average national annual solar rating / @profile.annual_solar_rating) / 1000.0) / (100% - @profile.system_performance_derate)" do
        number_with_precision(@engine.nameplate_rating(7000.0), 2).to_f.should == 4.04
      end
    end
    
    describe "when not provided with an output" do
      before(:each) do
        @engine.should_receive(:annual_output).and_return(7000.0)
      end
      
      it "should return the nameplate rating in kW required to generate the annual_output, calculated with (output / 1.89 * (average national annual solar rating / @profile.annual_solar_rating) / 1000.0) / (100% - @profile.system_performance_derate)" do
        number_with_precision(@engine.nameplate_rating, 2).to_f.should == 4.04
      end
    end
  end
  
  describe "#cec_rating" do
    before(:each) do
      stub_engine
    end
    
    describe "when provided with an output" do
      before(:each) do
        @engine.should_receive(:nameplate_rating).with(7000.0).and_return(4.03642145255279)
      end
      
      it "should return the CEC rating in kW required to generate the provided output annually by multiplying the nameplate rating with an AC/DC ratio of 0.85" do
        number_with_precision(@engine.cec_rating(7000.0), 2).to_f.should == 3.43
      end
    end
    
    describe "when not provided with an output" do
      before(:each) do
        @engine.should_receive(:annual_output).and_return(7000.0)
        @engine.should_receive(:nameplate_rating).with(7000.0).and_return(4.03642145255279)
      end
      
      it "should return the CEC rating in kW required to generate the annual_output by multiplying the nameplate rating with an AC/DC ratio of 0.85" do
        number_with_precision(@engine.cec_rating, 2).to_f.should == 3.43
      end
    end
  end
  
  describe "#cec_rating_without_derate" do
    before(:each) do
      stub_engine
      @engine.should_receive(:annual_output_without_derate).and_return(7000.0)
      @engine.should_receive(:cec_rating).with(7000.0).and_return(3.43095823466987)
    end
    
    it "should return the CEC rating in kW required to generate the annual_output_without_derate" do
      number_with_precision(@engine.cec_rating_without_derate, 2).to_f.should == 3.43
    end
  end
  
  describe "#cost_adjusted_size" do
    before(:each) do
      stub_engine
      @engine.should_receive(:cec_rating).twice.and_return(3.43095823466987)
    end
    
    it "should return the cost adjusted size of the system, calculated with cec_rating + 1 / ((cec_rating + 2) ** 2)" do
      number_with_precision(@engine.cost_adjusted_size, 2).to_f.should == 3.46
    end
  end
  
  describe "#monthly_cost_optimal_offset" do
    before(:each) do
      stub_engine
      @engine.should_receive(:monthly_electric_cost_by_offset).twice.and_return({ 0 => 120.0, 5 => 115.0, 10 => 115.0, 15 => 135.0 })
    end
    
    it "should return the maximum percentage usage offset for the lowest monthly cost" do
      @engine.monthly_cost_optimal_offset.should == 10
    end
  end
  
  
  #
  # System cost
  #
  
  describe "#system_cost" do
    before(:each) do
      stub_engine
      @engine.should_receive(:cost_adjusted_size).and_return(3.46486193291734)
    end
    
    it "should return the cost adjusted system size (converted to Watts) * system cost per AC Watt" do
      number_with_precision(@engine.system_cost, 2).to_f.should == 24254.03
    end
  end
  
  describe "#installation_cost" do
    before(:each) do
      stub_engine
      @engine.should_receive(:cost_adjusted_size).and_return(3.46486193291734)
    end
    
    it "should return the cost adjusted system size (converted to Watts) * installation cost per AC Watt" do
      number_with_precision(@engine.installation_cost, 2).to_f.should == 7622.7
    end
  end
  
  describe "#project_cost and #total_price" do
    before(:each) do
      stub_engine
      @engine.should_receive(:system_cost).twice.and_return(24254.0335304214)
      @engine.should_receive(:installation_cost).twice.and_return(7622.69625241815)
    end
    
    it "should return system_cost + installation_cost" do
      number_with_precision(@engine.project_cost, 2).to_f.should == 31876.73
      number_with_precision(@engine.total_price, 2).to_f.should == 31876.73
    end
  end
  
  describe "#sales_tax" do
    before(:each) do
      stub_engine
      @engine.should_receive(:system_cost).and_return(24254.0335304214)
      @engine.should_receive(:total_value_of_state_and_local_incentives).and_return(1000.0)
      @profile.should_receive(:sales_tax_rate).and_return(0.07)
    end
    
    it "should return system_cost less any incentives times the profile's sales tax rate" do
      number_with_precision(@engine.sales_tax, 2).to_f.should == 1627.78
    end
  end
  
  describe "#net_system_cost" do
    before(:each) do
      stub_engine
      @engine.should_receive(:project_cost).and_return(31876.7297828395)
      @engine.should_receive(:sales_tax).and_return(1627.7823471295)
      @engine.should_receive(:total_value_of_federal_incentives).and_return(2000.0)
      @engine.should_receive(:total_value_of_state_and_local_incentives).and_return(1000.0)
    end
    
    it "should return the project_cost + sales_tax - total_value_of_federal_incentives - total_value_of_state_and_local_incentives" do
      number_with_precision(@engine.net_system_cost, 2).to_f.should == 30504.51
    end
  end
  
  describe "#average_dollar_cost_per_nameplate_watt" do
    before(:each) do
      stub_engine
      @engine.should_receive(:total_price).and_return(31876.7297828395)
      @engine.should_receive(:nameplate_rating).and_return(4.03642145255279)
    end
    
    it "should return the total price / nameplate rating in Watts" do
      number_with_precision(@engine.average_dollar_cost_per_nameplate_watt, 2).to_f.should == 7.9
    end
  end
  
  describe "#average_dollar_cost_per_cec_watt" do
    before(:each) do
      stub_engine
      @engine.should_receive(:total_price).and_return(31876.7297828395)
      @engine.should_receive(:cec_rating).and_return(3.43095823466987)
    end
    
    it "should return the total price / CEC rating in Watts" do
      number_with_precision(@engine.average_dollar_cost_per_cec_watt, 2).to_f.should == 9.29
    end
  end
  
  describe "#average_dollar_system_cost_per_nameplate_watt" do
    before(:each) do
      stub_engine
      @engine.should_receive(:system_cost).and_return(24254.0335304214)
      @engine.should_receive(:nameplate_rating).and_return(4.03642145255279)
    end
    
    it "should return the system cost / nameplate rating in Watts" do
      number_with_precision(@engine.average_dollar_system_cost_per_nameplate_watt, 2).to_f.should == 6.01
    end
  end
  
  describe "#average_dollar_installation_cost_per_nameplate_watt" do
    before(:each) do
      stub_engine
      @engine.should_receive(:installation_cost).and_return(7622.69625241815)
      @engine.should_receive(:nameplate_rating).and_return(4.03642145255279)
    end
    
    it "should return the installation cost / nameplate rating in Watts" do
      number_with_precision(@engine.average_dollar_installation_cost_per_nameplate_watt, 2).to_f.should == 1.89
    end
  end
  
  describe "#average_dollar_system_cost_per_cec_watt" do
    before(:each) do
      stub_engine
      @engine.should_receive(:system_cost).and_return(24254.0335304214)
      @engine.should_receive(:cec_rating).and_return(3.43095823466987)
    end
    
    it "should return the system cost / CEC rating in Watts" do
      number_with_precision(@engine.average_dollar_system_cost_per_cec_watt, 2).to_f.should == 7.07
    end
  end
  
  describe "#average_dollar_installation_cost_per_cec_watt" do
    before(:each) do
      stub_engine
      @engine.should_receive(:installation_cost).and_return(7622.69625241815)
      @engine.should_receive(:cec_rating).and_return(3.43095823466987)
    end
    
    it "should return the installation cost / CEC rating in Watts" do
      number_with_precision(@engine.average_dollar_installation_cost_per_cec_watt, 2).to_f.should == 2.22
    end
  end
  
  
  #
  # Annual usage, output, and bill calculations
  #
  
  describe "#annual_usage" do
    before(:each) do
      stub_engine
    end
    
    it "should calculate the annual usage from the average monthly bill (adjusted by removing the state utility tax) using the appropriate tariff" do
      @profile.should_receive(:state).and_return('CA')
      @profile.should_receive(:average_monthly_bill).and_return(250.0)
      @profile.should_receive(:region).exactly(6).times.and_return('region')
      @tariff = mock_model(Tariff)
      @utility.should_receive(:tariff_for).exactly(6).times.with('region').and_return(@tariff)
      @tariff.should_receive(:fixed_amount).twice.and_return(0.0)
      
      @summer_tier_low = mock_model(VariableTier)
      @summer_tier_high = mock_model(VariableTier)
      @winter_tier_low = mock_model(VariableTier)
      @winter_tier_high = mock_model(VariableTier)
      @tariff.should_receive(:summer_variable_tiers).and_return([ @summer_tier_low, @summer_tier_high ])
      @tariff.should_receive(:winter_variable_tiers).and_return([ @winter_tier_low, @winter_tier_high ])
      
      @tariff.should_receive(:tiered_fixed_tiers).twice.and_return([])
      
      @summer_tier_low.should_receive(:max_tier_amount).exactly(3).times.and_return(55.9504)
      @summer_tier_low.should_receive(:max_usage).and_return(484)
      @summer_tier_high.should_receive(:max_tier_amount).and_return(0.0)
      @summer_tier_high.should_receive(:rate).and_return(0.34878)
      
      # usage should == 995.653859581604 at this point
      
      @utility.should_receive(:summer_starting_month).twice.and_return(5)
      @utility.should_receive(:summer_ending_month).twice.and_return(10)
      
      # usage should == 5973.92315748962 at this point
      
      @winter_tier_low.should_receive(:max_tier_amount).exactly(3).times.and_return(44.6216)
      @winter_tier_low.should_receive(:max_usage).and_return(386)
      @winter_tier_high.should_receive(:max_tier_amount).and_return(0.0)
      @winter_tier_high.should_receive(:rate).and_return(0.34878)
      
      # usage should == 930.135079835059 at this point
      
      # after summer/winter adjustment is made, usage should == 5580.81047901035
      
      number_with_precision(@engine.annual_usage, 2).to_f.should == 11554.73
    end
    
    it "should properly calculate the annual usage from the average monthly bill using the appropriate tariff when TieredFixedTiers are present" do
      @profile.should_receive(:state).and_return('CA')
      @profile.should_receive(:average_monthly_bill).and_return(250.0)
      @profile.should_receive(:region).exactly(6).times.and_return('region')
      @tariff = mock_model(Tariff)
      @utility.should_receive(:tariff_for).exactly(6).times.with('region').and_return(@tariff)
      @tariff.should_receive(:fixed_amount).twice.and_return(0.0)
      
      @summer_tier_low = mock_model(VariableTier)
      @summer_tier_high = mock_model(VariableTier)
      @winter_tier_low = mock_model(VariableTier)
      @winter_tier_high = mock_model(VariableTier)
      @tariff.should_receive(:summer_variable_tiers).and_return([ @summer_tier_low, @summer_tier_high ])
      @tariff.should_receive(:winter_variable_tiers).and_return([ @winter_tier_low, @winter_tier_high ])
      
      @tiered_fixed_low = mock_model(TieredFixedTier)
      @tiered_fixed_high = mock_model(TieredFixedTier)
      @tiered_fixed_low.should_receive(:max_usage).exactly(4).times.and_return(250.0)
      @tiered_fixed_high.should_receive(:max_usage).twice.and_return(nil)
      @tariff.should_receive(:tiered_fixed_tiers).twice.and_return([ @tiered_fixed_low, @tiered_fixed_high ])
      
      @summer_tier_low.should_receive(:rate).and_return(0.1156)
      @tiered_fixed_low.should_receive(:rate).exactly(4).times.and_return(5.6)
      
      @winter_tier_low.should_receive(:rate).and_return(0.1156)
      @tiered_fixed_high.should_receive(:rate).twice.and_return(83.29)
      
      # cumulative_amount should == 83.29 at this point
      
      @summer_tier_low.should_receive(:max_tier_amount).exactly(3).times.and_return(55.9504)
      @summer_tier_low.should_receive(:max_usage).and_return(484)
      @summer_tier_high.should_receive(:max_tier_amount).and_return(0.0)
      @summer_tier_high.should_receive(:rate).and_return(0.34878)
      
      # usage should == 756.850029086736 at this point
      
      @utility.should_receive(:summer_starting_month).twice.and_return(5)
      @utility.should_receive(:summer_ending_month).twice.and_return(10)
      
      # usage should == 4541.10017452041 at this point
      
      @winter_tier_low.should_receive(:max_tier_amount).exactly(3).times.and_return(44.6216)
      @winter_tier_low.should_receive(:max_usage).and_return(386)
      @winter_tier_high.should_receive(:max_tier_amount).and_return(0.0)
      @winter_tier_high.should_receive(:rate).and_return(0.34878)
      
      # usage should == 691.331249340191 at this point
      
      # after summer/winter adjustment is made, usage should == 4147.98749604114
      
      number_with_precision(@engine.annual_usage, 2).to_f.should == 8689.09
      pending("need to add examples for if adjusted_average_monthly_bill <= max_fixed_tier_amount")
    end
  end
  
  describe "#annual_output" do
    before(:each) do
      stub_engine
    end
    
    describe "when not provided with a specific year (or when provided with year 1)" do
      before(:each) do
        @engine.should_receive(:annual_usage).twice.and_return(11554.7336365)
        @profile.should_receive(:usage_offset).twice.and_return(0.55)
      end
      
      it "should return the annual_usage * profile's usage_offset" do
        number_with_precision(@engine.annual_output, 2).to_f.should == 6355.1
        number_with_precision(@engine.annual_output(1), 2).to_f.should == 6355.1
      end
    end
    
    describe "when provided with a specific year > 1" do
      before(:each) do
        @engine.should_receive(:annual_usage).and_return(11554.7336365)
        @profile.should_receive(:usage_offset).and_return(0.55)
      end
      
      it "should return the annual_usage * profile's usage_offset * system efficiency at year n (100% - (0.005% ** (n - 1)))" do
        number_with_precision(@engine.annual_output(2), 2).to_f.should == 6323.33
      end
    end
  end
  
  describe "#annual_usage_after" do
    before(:each) do
      stub_engine
    end
    
    describe "when not provided with a specific year (or when provided with year 1)" do
      before(:each) do
        @engine.should_receive(:annual_usage).twice.and_return(11554.7336365)
        @engine.should_receive(:annual_output).with(1).twice.and_return(6355.103500075)
      end
      
      it "should return the annual_usage * profile's usage_offset" do
        number_with_precision(@engine.annual_usage_after, 2).to_f.should == 5199.63
        number_with_precision(@engine.annual_usage_after(1), 2).to_f.should == 5199.63
      end
    end
    
    describe "when provided with a specific year > 1" do
      before(:each) do
        @engine.should_receive(:annual_usage).and_return(11554.7336365)
        @engine.should_receive(:annual_output).with(2).and_return(6323.32798257462)
      end
      
      it "should return the annual_usage * profile's usage_offset * system efficiency at year n (100% - (0.005% ** (n - 1)))" do
        number_with_precision(@engine.annual_usage_after(2), 2).to_f.should == 5231.41
      end
    end
  end
  
  def stub_engine
    @profile = mock_model(Profile)
    @utility = mock_model(Utility)
    @profile.stub!(:utility).and_return(@utility)
    @engine = CalculationEngine.new(@profile)
  end
  
  def number_with_precision(number, precision = 0)
    "%01.#{precision}f" % number
  rescue
    number
  end
end