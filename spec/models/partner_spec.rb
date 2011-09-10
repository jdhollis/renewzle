require File.dirname(__FILE__) + '/../spec_helper'

describe Partner do
  before(:each) do
    @partner = Partner.new
  end
  
  it "should belong to a company" do
    @partner.should respond_to(:company)
  end

  it "should have many quotes" do
    @partner.should respond_to(:quotes)
  end

  it "should have many leads" do
    @partner.should respond_to(:leads)
  end

  it "should have many purchased leads" do
    @partner.should respond_to(:purchased_leads)
  end

  it "should have many unpurchased leads" do
    @partner.should respond_to(:unpurchased_leads)
  end
	
  it "should require a phone number" do
    @partner.should have(2).errors_on(:phone_number)
    @partner.errors.on(:phone_number).should include("can't be blank")
    @partner.phone_number = '574 304 1187'
    @partner.should have(:no).errors_on(:phone_number)
  end
  
  it "should require a phone number that is less than or equal to 255 characters in length" do
    long_phone_number = ''
    0.upto(256) { |i| long_phone_number << i.to_s  }
    @partner.phone_number = long_phone_number
    @partner.should have(1).error_on(:phone_number)
    @partner.errors.on(:phone_number).should == 'is too long (maximum is 255 characters)'
  end
  
  it "should allow phone_number to be changed via mass-assignment" do
    @partner.phone_number.should be_blank
    @partner.attributes = { :phone_number => '574 304 1187' }
    @partner.phone_number.should == '574 304 1187'
  end
  
  it "should delegate lead_price_given to :company" do
    @company = mock_model(Company)
    @company.should_receive(:lead_price_given)
    @partner.company = @company
    @partner.lead_price_given
  end

  describe "#rfqs" do
    it "should find profile rfqs" do
      Profile.should_receive(:find_rfqs)
      @partner.rfqs
    end
  end

  describe "#quotes_by_rfq" do
    it "should find quotes and group by profile_id" do
      @enum = mock('enum')
      @enum.should_receive(:group_by)
      @partner.should_receive(:quotes).and_return(@enum)
      @partner.quotes_by_rfq
    end
  end

  describe "#has_purchased_leads?" do
    it "should check if purchased_leads is blank?" do
      @partner.should_receive(:purchased_leads)
      @partner.has_purchased_leads?
    end
  end

  describe "#approve!" do
    it "should set :waiting_approval to false" do
      @partner.should_receive(:update_attribute).with(:waiting_approval, false)
      @partner.approve!
    end
  end

  describe "#decline!" do
    it "should destroy partner" do
      @partner.should_receive(:destroy)
      @partner.decline!
    end
  end
  
  describe "if no other partners are associated with the company on create" do
    before(:each) do
      @company = mock_model(Company)
      @partners = mock("partners has_many relationship")
      @company.should_receive(:partners).and_return(@partners)
      @partners.should_receive(:count).and_return(0)
      @partner.company = @company
      stub_valid_partner
    end
    
    it "should set :company_administrator to true" do
      @partner.company_administrator?.should be(false)
      @partner.save!
      @partner.company_administrator?.should be(true)
    end
    
    it "should set :can_update_company_profile to true" do
      @partner.can_update_company_profile?.should be(false)
      @partner.save!
      @partner.can_update_company_profile?.should be(true)      
    end
    
    it "should set :can_submit_quotes to true" do
      @partner.can_submit_quotes?.should be(false)
      @partner.save!
      @partner.can_submit_quotes?.should be(true)      
    end
    
    it "should set :can_purchase_leads to true" do
      @partner.can_purchase_leads?.should be(false)
      @partner.save!
      @partner.can_purchase_leads?.should be(true)      
    end
  end
  
  describe "if other partners are associated with the company on create" do
    before(:each) do
      @company = mock_model(Company)
      @partners = mock("partners has_many relationship")
      @company.should_receive(:partners).and_return(@partners)
      @partners.should_receive(:count).and_return(1)
      @partner.company = @company
      stub_valid_partner
    end
    
    it "should :company_administrator should remain false" do
      @partner.company_administrator?.should be(false)
      @partner.save!
      @partner.company_administrator?.should be(false)
    end
    
    it "should :can_update_company_profile should remain false" do
      @partner.can_update_company_profile?.should be(false)
      @partner.save!
      @partner.can_update_company_profile?.should be(false)      
    end
    
    it "should :can_submit_quotes should remain false" do
      @partner.can_submit_quotes?.should be(false)
      @partner.save!
      @partner.can_submit_quotes?.should be(false)      
    end
    
    it "should :can_purchase_leads should remain false" do
      @partner.can_purchase_leads?.should be(false)
      @partner.save!
      @partner.can_purchase_leads?.should be(false)      
    end
  end
  
  def stub_valid_partner
    @partner.first_name = 'J.D.'
    @partner.last_name = 'Hollis'
    @partner.email = 'jd@greenoptions.com'
    @partner.password = 'password'
    @partner.password_confirmation = 'password'
    @partner.phone_number = '+1 574 304 1187'
  end
end