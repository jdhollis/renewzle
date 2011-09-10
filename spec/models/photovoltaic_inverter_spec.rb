require File.dirname(__FILE__) + '/../spec_helper'

describe PhotovoltaicInverter do
  before(:each) do
    @inverter = PhotovoltaicInverter.new
  end

	describe "#find_manufacturers" do
		it "should find all inverters by distinct manufacturer" do
			PhotovoltaicInverter.should_receive(:find).with(:all, :select => 'DISTINCT(manufacturer) AS manufacturer')
			PhotovoltaicInverter.find_manufacturers
		end
	end

	describe "#model_and_description" do
		it "should return a concatenated string" do
			@inverter.should_receive(:model_number).and_return(1000)
			@inverter.should_receive(:description).and_return('Solar Inverter')
			@inverter.model_and_description.should == '1000 Solar Inverter'
		end
	end
end
