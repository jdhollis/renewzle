require File.dirname(__FILE__) + '/../spec_helper'

describe PercentageOfProjectCostIncentive do
  before(:each) do
    @incentive = PercentageOfProjectCostIncentive.new
  end

  describe "#value_for" do
    before(:each) do
      @profile = mock_model(Profile)
    end

    describe "when the qoute is not applicable" do
      it "should return 0.0" do
        @incentive.should_receive(:applicable_to).with(@profile).and_return(false)
        @incentive.value_for(@profile).should == 0.0
      end
    end

    describe "when the qoute is applicable" do
      before(:each) do
        @profile.should_receive(:project_cost).and_return(1000.0)
        @incentive.should_receive(:rate).and_return(10.0)
      end

      describe "when maximum amount is blank?" do
        it "should return the profile project cost" do
          @incentive.value_for(@profile).should == 10000.0
        end
      end

      describe "when maximum amount is not blank?" do
        describe "when the profile/quote project cost is lower than the maximum amount" do
          it "should return the profile/quote cost" do
            @incentive.stub!(:maximum_amount).and_return(1000000.0)
            @incentive.value_for(@profile).should == 10000.0
          end
        end

        describe "when the profile/quote project cost is less than the maximum amount" do
          it "should return the incentives maximum amount" do
            @incentive.stub!(:maximum_amount).and_return(100.0)
            @incentive.value_for(@profile).should == 100.0
          end
        end
      end
    end
  end
end
