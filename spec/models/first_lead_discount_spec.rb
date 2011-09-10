require File.dirname(__FILE__) + '/../spec_helper'

describe FirstLeadDiscount do
  before(:each) do
    @discount = stub_model(FirstLeadDiscount)
  end

  describe "#apply_to" do
    it "should apply discount if it is the companys first lead" do
      @lead = stub_model(Lead)
      @company = stub_model(Company)
      @lead.stub!(:company).and_return(@company)
      @lead.should_receive(:companys_first_lead?).and_return(true)
      @discount.apply_to(1000, @lead).should be_nil
    end

    it "should not apply the discount if it is not the companys first lead" do
      @lead = stub_model(Lead)
      @company = stub_model(Company)
      @lead.stub!(:company).and_return(@company)
      @lead.should_receive(:companys_first_lead?).and_return(false)
      @discount.apply_to(1000, @lead).should == 1000
    end
  end
end
