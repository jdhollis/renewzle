require File.dirname(__FILE__) + '/../spec_helper'

describe PhotovoltaicModule do
  before(:each) do
    @module = PhotovoltaicModule.new
  end

	describe "#find_manufacturers" do
		it "should find all modules by distinct manufacturer" do
			PhotovoltaicModule.should_receive(:find).with(:all, :select => 'DISTINCT(manufacturer) AS manufacturer')
			PhotovoltaicModule.find_manufacturers
		end
	end

	describe "#model_and_description" do
		it "should return a concatenated string" do
			@module.should_receive(:model_number).and_return(1000)
			@module.should_receive(:description).and_return('Solar Module')
			@module.model_and_description.should == '1000 Solar Module'
		end
	end
end
