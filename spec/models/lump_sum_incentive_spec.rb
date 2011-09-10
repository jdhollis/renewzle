require File.dirname(__FILE__) + '/../spec_helper'

describe LumpSumIncentive do
  before(:each) do
    @incentive = LumpSumIncentive.new
  end

  describe "#value_for" do
    before(:each) do
      @profile = mock_model(Profile)
    end

    it "should return the incentive rate" do
      @incentive.should_receive(:applicable_to).with(@profile).and_return(true)
      @incentive.should_receive(:rate).and_return(10.0)
      @incentive.value_for(@profile).should == 10.0
    end
    
    describe "if the qoute is not applicable" do
      it "should return 0.0" do
        @incentive.should_receive(:applicable_to).with(@profile).and_return(false)
        @incentive.value_for(@profile).should == 0.0
      end
    end
  end
end
