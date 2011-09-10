require File.dirname(__FILE__) + '/../spec_helper'

describe Tariff do
  before(:each) do
    @tariff = Tariff.new
  end
  
  it "should have many fixed tiers" do
    @tariff.should respond_to(:fixed_tiers)
  end
  
  it "should have many tiered fixed tiers" do
    @tariff.should respond_to(:tiered_fixed_tiers)
  end
  
  describe "#tiered_fixed_amount_for a usage" do
    before(:each) do
      @low_usage = 125.0
      @high_usage = 1002.0
      @tiered_fixed_tier_low = mock_model(TieredFixedTier)
      @tiered_fixed_tier_low.should_receive(:min_usage).and_return(0.0)
      @tiered_fixed_tier_low.should_receive(:max_usage).exactly(4).times.and_return(250.0)
      @tiered_fixed_tier_low.should_receive(:rate).and_return(5.6)
      
      @tiered_fixed_tier_medium = mock_model(TieredFixedTier)
      @tiered_fixed_tier_medium.should_receive(:max_usage).twice.and_return(550.0)
      
      @tiered_fixed_tier_high = mock_model(TieredFixedTier)
      @tiered_fixed_tier_high.should_receive(:max_usage).and_return(nil)
      @tiered_fixed_tier_high.should_receive(:min_usage).and_return(1001.0)
      @tiered_fixed_tier_high.should_receive(:rate).and_return(83.29)
      @tariff.tiered_fixed_tiers = [ @tiered_fixed_tier_low, @tiered_fixed_tier_medium, @tiered_fixed_tier_high ]
    end
    
    it "should return the appropriate tiered fixed amount for the usage" do
      @tariff.tiered_fixed_amount_for(@low_usage).should == 5.6
      @tariff.tiered_fixed_amount_for(@high_usage).should == 83.29
    end
  end
end