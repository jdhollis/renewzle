require File.dirname(__FILE__) + '/../spec_helper'

describe Company do
  before(:each) do
    @company = Company.new
  end

  it "should have many discounts" do
    @company.should respond_to(:discounts)
  end
  
  it "should require a name" do
    @company.should have(1).error_on(:name)
    @company.name = 'Renewzle'
    @company.should have(:no).errors_on(:name)
  end
  
  it "should require a name that is less than or equal to 255 characters in length" do
    long_name = ''
    0.upto(256) { |i| long_name << i.to_s  }
    @company.name = long_name
    @company.should have(1).error_on(:name)
    @company.errors.on(:name).should == 'is too long (maximum is 255 characters)'
  end
  
  it "should require a unique name" do
    Company.new(:name => 'Renewzle').save(false)
    @company.name = 'Renewzle'
    @company.should have(1).error_on(:name)
    @company.errors.on(:name).should == 'has already been taken'
  end
  
  it "should allow name to be changed via mass-assignment" do
    @company.name.should be_blank
    @company.attributes = { :name => 'Renewzle' }
    @company.name.should == 'Renewzle'
  end
  
  it "should not allow claimed to be changed via mass-assignment" do
    @company.claimed.should be(false)
    @company.attributes = { :claimed => true }
    @company.claimed.should be(false)
  end
  
  it "should have many partners" do
    @company.should respond_to(:partners)
  end
  
  it "should have dependent partners" do
    @partner = mock_model(Partner)
    @partner.stub!(:[])
    @partner.should_receive(:destroy)
    @company.partners << @partner
    @company.destroy
  end
  
  describe "when it has no partners" do    
    it "should not be claimed" do
      @company.should_not be_claimed
    end
    
    it "should return false for :has_partners?" do
      @company.should_not have_partners
    end
  end
  
  describe "when it has at least one partner" do
    before(:each) do
      @partner = mock_model(Partner)
      @partner.stub!(:[])
      @company.partners << @partner
    end
    
    it "should be claimed" do
      @company.should be_claimed
    end
    
    it "should return true for :has_partners?" do
      @company.should have_partners
    end
  end
  
  describe "when all its partners have been removed" do
    before(:each) do
      @partner = mock_model(Partner)
      @partner.stub!(:[])
      @partner.stub!(:destroy)
    end
    
    it "should not be claimed" do
      @company.partners << @partner
      @company.should be_claimed
      @company.partners = []
      @company.should_not be_claimed
    end
  end
  
  describe "#update_from" do
    before(:each) do
      @params = { 'id' => '1' }
    end
    
    it "should set attributes to params" do
      @company.should_receive(:attributes=).with(@params)
      @company.stub!(:save!)
      @company.update_from(@params)
    end
    
    it "should save! the company" do
      @company.stub!(:attributes=)
      @company.should_receive(:save!)
      @company.update_from(@params)
    end
  end
  
  describe "#register" do
    before(:each) do
      @params = 'params'
      @partner = mock_model(Partner)
      @partners = mock('partners')
    end
    
    it "should build a partner via the partners relationship" do
      @company.should_receive(:partners).and_return(@partners)
      @partners.should_receive(:build).with(@params).and_return(@partner)
      @company.register(@params).should be(@partner)
    end
  end

  describe "#lead_price_given" do
    it "should return a price calculated from the companies discounts" do
      @discount = mock_model(Discount)
      @discount.should_receive(:apply_to).with(100, @lead).and_return(75)
      @discounts = [ @discount ]
      @company.should_receive(:discounts).and_return(@discounts)
      @company.lead_price_given(100, @lead).should == 75
    end
  end
end
