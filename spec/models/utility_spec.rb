require File.dirname(__FILE__) + '/../spec_helper'

describe Utility do
  before(:each) do
    @utility = Utility.new
  end
  
  it "should have many incentives" do
    @utility.should respond_to(:incentives)
  end

  it "should have many incentives that are found by region" do
    @utility.tariffs.for_region('South West').should == []
  end
  
  it "should have a dependent incentive" do
    @incentive = mock_model(Incentive)
    @incentive.should_receive(:destroy)
    @utility.incentives << @incentive
    @utility.destroy
  end

  it "should have many tariffs" do
    @utility.should respond_to(:tariffs)
  end
  
  it "should have a dependent tariff" do
    @tariff = mock_model(Tariff)
    @tariff.should_receive(:destroy)
    @utility.tariffs << @tariff
    @utility.destroy
  end

  describe "#source_mix" do
    it "should return hash of values with description keys" do
      @utility.percent_coal = 50.0
      @utility.source_mix.should == { 'Coal' => 50.0 }
    end
  end

  [ :co2, :so2, :nox, :mercury ].each do |which|
    describe "##{which}_emissions_given" do
      before(:each) do
        CalculationEngine.should_receive(:send).and_return(100)
      end

      it "should return #emmissions_given for usage when #{which}_rate is blank?" do
        @utility.send("#{which}_emissions_given", 10).should == 100
      end

      it "should return #emmissions_given for usage with rate when #{which}_rate is not blank?" do
        @utility.send("#{which}_rate=", 1)
        @utility.send("#{which}_emissions_given", 10).should == 100
      end
    end
  end

  describe "#electricity_rate" do
    it "should return rate when rate is not blank?" do
      @utility.rate = 1
      @utility.electricity_rate.should == 1
    end

    it "should return 0.08547 when rate is blank?" do
      @utility.electricity_rate.should == 0.08547 
    end
  end

  describe "#tariffs_for" do
    before(:each) do
      @region = 'South West'
    end

    it "should find first tariff for region when there are regions" do
      @regions = [ @region, mock('region') ]
      @utility.tariffs.should_receive(:for_region).and_return(@regions)
      @utility.tariffs.should_receive(:size).and_return(2)
      @utility.tariff_for(@region).should == @region
    end

    it "should return nil when there are no regions" do
      @utility.should_receive(:has_tariffs_for).with(@region).and_return(false)
      @utility.tariff_for(@region).should be_nil
    end
  end

  describe "#season_for" do
    describe "when summer_starting_month is 'May' and summer_ending_month is 'September'" do
      it "should return 'Summer' for July" do
        @utility.season_for(DateTime.new(y=2000,m=7,d=1)).should == 'Summer'
      end

      it "should return 'Winter' for December" do
        @utility.season_for(DateTime.new(y=2000,m=12,d=1)).should == 'Winter'
      end
    end
  end

  describe "#load_for" do
    it "should return load if load is not blank?" do
      @utility.jan = 1
      @utility.load_for(DateTime.new(y=2000,m=1,d=1)).should == 1
    end

    it "should return (1 / 12.0) when load is blank?" do
      @utility.load_for(Time.now).should == (1 / 12.0)
    end
  end

  describe "#has_region_map?" do
    it "should return the !value of region_map.blank?" do
      @utility.region_map.should_receive(:blank?).and_return(false)
      @utility.has_region_map?.should == true
    end
  end
end
