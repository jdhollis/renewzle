require File.dirname(__FILE__) + '/../spec_helper'

describe ExemptionIncentive do
  before(:each) do
    @incentive = ExemptionIncentive.new
  end

  describe "#value_for" do
    it "should return 0.0" do
      @profile = mock_model(Profile)
      @incentive.value_for(@profile).should == 0.0
    end
  end
end
