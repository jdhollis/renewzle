require File.dirname(__FILE__) + '/../spec_helper'

describe PerWattIncentive do
  before(:each) do
    @incentive = PerWattIncentive.new
  end

  describe "#derate?" do
    it "should return the incentive derate value" do
      @incentive.should_receive(:derate).and_return(true)
      @incentive.derate?.should == true
    end
  end

  describe "#value_for" do
    before(:each) do
      @profile = mock_model(Profile)
    end

    describe "when profile/quote is not applicable" do
      it "should return 0.0" do
        @incentive.should_receive(:applicable_to).with(@profile).and_return(false)
        @incentive.value_for(@profile).should == 0.0
      end
    end

    describe "when profile/quote is applicable" do
      before(:each) do
        @incentive.should_receive(:watts_for).with(@profile).and_return(100.0)
        @incentive.should_receive(:rate).and_return(10.0)
      end

      describe "when maximum_amount and maximum_percentage are blank?" do
        it "should return the watts for the profile" do
          @incentive.value_for(@profile).should == 1000.00
        end
      end

      describe "when maximum_amount is not blank" do
        describe "when watts_for profile are lower than the incentives maximum_amount" do
          it "should return the profile watts" do
            @incentive.stub!(:maximum_amount).and_return(5000.0)
            @incentive.value_for(@profile).should == 1000.0
          end
        end

        describe "when watts_for profile are greater than the incentives maximum_amount" do
          it "should return the profile watts" do
            @incentive.stub!(:maximum_amount).and_return(500.0)
            @incentive.value_for(@profile).should == 500.0
          end
        end
      end

      describe "when maximum_percentage is not blank" do
        before(:each) do
          @profile.should_receive(:total_price).and_return(1000.0)
        end

        describe "when watts_for profile are lower than the incentives maximum_percentage" do
          it "should return the profile watts" do
            @incentive.stub!(:maximum_percentage).and_return(5000.0)
            @incentive.value_for(@profile).should == 1000.0
          end
        end

        describe "when watts_for profile are greater than the incentives maximum_percentage" do
          it "should return the profile watts" do
            @incentive.stub!(:maximum_percentage).and_return(0.50)
            @incentive.value_for(@profile).should == 500.0
          end
        end
      end
    end
  end
end
