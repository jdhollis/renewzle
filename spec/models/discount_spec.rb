require File.dirname(__FILE__) + '/../spec_helper'

describe Discount do
  before(:each) do
    @discount = Discount.new
  end

  it "should require a percentage to be a number" do
    @discount.percentage = 'not a percentage'
    @discount.should have(1).error_on(:percentage)
    @discount.errors.on(:percentage).should == 'is not a number'
  end

  it "should allow percentage to be nil" do
    @discount.percentage = nil
    @discount.should_not have(1).error_on(:percentage)
  end

  it "should require a price to be a number" do
    @discount.price = 'not a price'
    @discount.should have(1).error_on(:price)
    @discount.errors.on(:price).should == 'is not a number'
  end

  it "should allow price to be nil" do
    @discount.price = nil
    @discount.should_not have(1).error_on(:price)
  end

  [ :company_id, :price, :percentage ].each do |attribute|
    it "should allow #{attribute} to be changed via mass-assignment" do
      @discount.attributes = { attribute.to_sym => 1 }
      @discount.send(attribute).should == 1
    end
  end

  describe "when asked for all global discounts" do
    describe "and no global discounts exist" do
      it "should return an empty array" do
        Discount.global.should == []
      end
    end
    
    describe "and global discounts exist" do
      before(:each) do
        @global_discount_1 = Discount.create
        @global_discount_2 = Discount.create
        @individual_discount = Discount.create(:company_id => 1)
      end
      
      it "should return all of the global discounts" do
        Discount.global.should == [ @global_discount_1, @global_discount_2 ]
      end
    end
  end
  
  describe "when asked whether it is global" do
    before(:each) do
      @discount = Discount.new
    end
    
    describe "and it is not assigned to a specific company" do
      it "should return true" do
        @discount.global?.should be(true)
      end
    end
    
    describe "and it is assigned to a specific company" do
      before(:each) do
        @discount.company_id = 1
      end
      
      it "should return false" do
        @discount.global?.should be(false)
      end
    end
  end
  
  describe "when asked to discount a price" do
    before(:each) do
      @discount = Discount.new
      @current_price = 500.0
      @lead = mock_model(Lead)
    end
   
    describe "and the :percentage is not set" do
      before(:each) do
        @price = 10.0
        @discount.price = @price
      end

      it "should discount the price to :price" do
        @discount.apply_to(@current_price, @lead).should be(@price)
      end
    end

    describe "and the :price is not set" do
      before(:each) do
        @percentage = 0.5
        @discount.percentage = @percentage
        @adjusted_price = @current_price * @percentage
      end

      it "should discount the price by :percentage" do
        @discount.apply_to(@current_price, @lead).should == @adjusted_price
      end
    end
  end
end
