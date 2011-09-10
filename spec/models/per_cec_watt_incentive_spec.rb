require File.dirname(__FILE__) + '/../spec_helper'

describe PerCecWattIncentive do
  before(:each) do
    @incentive = PerCecWattIncentive.new
  end

  describe "#watts_for" do
    before(:each) do
      @profile = mock_model(Profile)
      @cec_rating = mock('cec_rating', :kw => 1.0)
      @cec_rating_without_derate = mock('cec_rating_without_derate', :kw => 10.0)
      @profile.stub!(:cec_rating).and_return(@cec_rating)
      @profile.stub!(:cec_rating_without_derate).and_return(@cec_rating_without_derate)
    end

    it "should return the profiles cec_rating kw" do
      @incentive.should_receive(:derate).and_return(true)
      @incentive.watts_for(@profile).should == 1.0
    end
    
    describe "when incentive is derated" do
      it "should return the profiles cec_rating kw without derate" do
        @incentive.should_receive(:derate).and_return(false)
        @incentive.watts_for(@profile).should == 10.0
      end
    end
  end
end
