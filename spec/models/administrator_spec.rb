require File.dirname(__FILE__) + '/../spec_helper'

describe Administrator do
  before(:each) do
    @admin = Administrator.new
  end
  
  it "should require a time zone" do
    @admin.should have(1).error_on(:time_zone)
    @admin.time_zone = 'America/New_York'
    @admin.should have(:no).errors_on(:time_zone)
  end
  
  it "should allow time_zone to be changed via mass-assignment" do
    @admin.time_zone.should be_blank
    @admin.attributes = { :time_zone => 'America/New_York' }
    @admin.time_zone.should == 'America/New_York'
  end
  
  describe "#masquerade_as provided with a user object" do
    before(:each) do
      @customer = mock_model(Customer)
    end
    
    it "should set :mask to the user object" do
      @admin.stub!(:save!)
      @admin.masquerade_as(@customer)
      @admin.mask.should be(@customer)
    end
    
    it "should save!" do
      @admin.should_receive(:save!)
      @admin.masquerade_as(@customer)
    end
  end
  
  describe "#stop_masquerading!" do
    before(:each) do
      @customer = mock_model(Customer)
      @admin.mask = @customer
    end
    
    it "should set :mask to nil" do
      @admin.stub!(:save!)
      @admin.stop_masquerading!
      @admin.mask.should be(nil)
    end
    
    it "should save!" do
      @admin.should_receive(:save!)
      @admin.stop_masquerading!
    end
  end
  
  describe "#masquerading?" do
    describe "when the administrator is masquerading as another user" do
      before(:each) do
        @admin.stub!(:save!)
        @admin.masquerade_as(mock_model(Customer))
      end
      
      it "should return true" do
        @admin.masquerading?.should be(true)
      end
    end
    
    describe "when the administrator is not masquerading as another user" do
      it "should return false" do
        @admin.masquerading?.should be(false)
      end
    end
  end
  
  describe "masquerading_as? with a User type" do
    describe "if mask is of the provided type" do
      before(:each) do
        @admin.mask = mock_model(Customer)
      end
      
      it "should return true" do
        @admin.masquerading_as?(Customer).should be(true)
      end
    end
    
    describe "if mask is blank" do
      it "should return false" do
        @admin.masquerading_as?(Customer).should be(false)
      end
    end
    
    describe "if mask is not of the provided type" do
      before(:each) do
        @admin.mask = mock_model(Partner)
      end
      
      it "should return false" do
        @admin.masquerading_as?(Customer).should be(false)
      end
    end
  end
end