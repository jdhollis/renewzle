require File.dirname(__FILE__) + '/../spec_helper'

describe PerKwhIncentive do
  before(:each) do
    @incentive = PerKwhIncentive.new
  end

  describe "#value_for" do
    before(:each) do
      @profile = mock_model(Profile)
    end

    describe "when the profile/quote is not applicable" do
      it "should return 0.0" do
        @incentive.should_receive(:applicable_to).with(@profile).and_return(false)
        @incentive.value_for(@profile).should == 0.0
      end
    end

    describe "when the profile/quote is applicable" do
      before(:each) do
        @profile.should_receive(:annual_output).and_return(10.0)
        @incentive.should_receive(:rate).twice.and_return(10.0)
      end

      describe "when maximum_amount and maximum_percentage are blank?" do
        it "should return the value of the profiles annual_output * rate" do
          @incentive.value_for(@profile).should == 100.0
        end
      end

      describe "when maximum_amount is not blank?" do
        describe "when the incentives maximum amout is lower than the profiles annual_output" do
          it "should return the incentives maximum amount" do
            @incentive.stub!(:maximum_amount).and_return(50.0)
            @incentive.value_for(@profile).should == 50.0
          end
        end

        describe "when the profiles annual_output is lower than the incentives maximum_amount" do
          it "should return the incentives maximum amount" do
            @incentive.stub!(:maximum_amount).and_return(200.0)
            @incentive.value_for(@profile).should == 100.0
          end
        end
      end

      describe "when maximum_percentage is not blank?" do
        before(:each) do
          @profile.should_receive(:total_price).and_return(10.0)
        end

        describe "when the incentives maximum percentage is lower than the profiles annual_output" do
          it "should return the incentives maximum percentage" do
            @incentive.stub!(:maximum_percentage).and_return(5.0)
            @incentive.value_for(@profile).should == 50.0
          end
        end

        describe "when the profiles annual_output is lower than the incentives maximum_percentage" do
          it "should return the incentives maximum percentage" do
            @incentive.stub!(:maximum_percentage).and_return(200.0)
            @incentive.value_for(@profile).should == 100.0
          end
        end
      end
    end
  end
end
