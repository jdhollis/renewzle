require File.dirname(__FILE__) + '/../spec_helper'

describe Incentive do
  before(:each) do
    @incentive = Incentive.new
  end

  it "should belong to a utility" do
    @incentive.should respond_to(:utility)
  end

  [ :city, :state, :source, :description, :notes, :utility_id, :rate, :minimum_system_size, :maximum_system_size, :maximum_amount, :maximum_percentage ].each do |attribute|
    it "should allow #{attribute} to be changed via mass-assignment" do
      @incentive.attributes = { attribute.to_sym => 1 }
      @incentive.send(attribute).should == 1
    end
  end

  [ :derate ].each do |attribute|
    it "should allow #{attribute} to be changed via mass-assignment" do
      @incentive.attributes = { attribute.to_sym => true }
      @incentive.send(attribute).should == true
    end
  end
  
  describe "#update_from" do
    before(:each) do
      @params = { 'id' => '1' }
    end
    
    it "should set attributes to params" do
      @incentive.should_receive(:attributes=).with(@params)
      @incentive.stub!(:save!)
      @incentive.update_from(@params)
    end
    
    it "should save! the incentive" do
      @incentive.stub!(:attributes=)
      @incentive.should_receive(:save!)
      @incentive.update_from(@params)
    end
  end

  describe "#applicable_to" do
    before(:each) do
      @profile = mock_model(Profile)
    end

    describe "when minimum_system_size and maximum_system_size are blank?" do
      it "should return true" do
        @incentive.applicable_to(@profile).should == true
      end
    end

    describe "when minimum_system_size and maximum_system_size are not blank?" do
      describe "and profile rating is less than minimum size" do
        it "should return false" do
          @incentive.minimum_system_size = 1
          @profile.stub!(:nameplate_rating).and_return(0)
          @incentive.applicable_to(@profile).should == false
        end
      end

      describe "and profile rating is greater than minimum size" do
        it "should return true" do
          @incentive.minimum_system_size = 0
          @profile.stub!(:nameplate_rating).and_return(1)
          @incentive.applicable_to(@profile).should == true
        end
      end

      describe "and profile rating is less than maximum size" do
        it "should return true" do
          @incentive.maximum_system_size = 1
          @profile.stub!(:nameplate_rating).and_return(0)
          @incentive.applicable_to(@profile).should == true
        end
      end

      describe "and profile rating is greater than maximum size" do
        it "should return false" do
          @incentive.maximum_system_size = 0
          @profile.stub!(:nameplate_rating).and_return(1)
          @incentive.applicable_to(@profile).should == false
        end
      end
    end
  end
end
