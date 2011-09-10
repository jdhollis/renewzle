require File.dirname(__FILE__) + '/../spec_helper'

describe PerNameplateWattIncentive do
  before(:each) do
    @incentive = PerNameplateWattIncentive.new
  end

  describe "#watts_for" do
    it "should return the profiles nameplate rating kw" do
      @profile = mock_model(Profile)
      @nameplate_rating = mock('nameplate_rating')
      @nameplate_rating.should_receive(:kw).and_return(10.0)
      @profile.should_receive(:nameplate_rating).and_return(@nameplate_rating)
      @incentive.watts_for(@profile).should == 10.0
    end
  end
end
