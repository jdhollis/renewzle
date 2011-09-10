require File.dirname(__FILE__) + '/../spec_helper'

describe Customer do
  before(:each) do
    @customer = Customer.new
  end
  
  it "should have a profile" do
    @customer.should respond_to(:profile)
  end
  
  it "should have a dependent profile" do
    @profile = mock_model(Profile)
    @profile.should_receive(:destroy)
    @customer.profile = @profile
    @customer.destroy
  end
  
  it "should require a street address" do
    @customer.should have(2).errors_on(:street_address)
    @customer.errors.on(:street_address).should include("can't be blank")
    @customer.street_address = '3003 Benham Avenue'
    @customer.should have(:no).errors_on(:street_address)
  end
  
  it "should require a street address that is less than or equal to 255 characters in length" do
    long_street_address = ''
    0.upto(256) { |i| long_street_address << i.to_s  }
    @customer.street_address = long_street_address
    @customer.should have(1).error_on(:street_address)
    @customer.errors.on(:street_address).should == 'is too long (maximum is 255 characters)'
  end
  
  it "should allow street_address to be changed via mass-assignment" do
    @customer.street_address.should be_blank
    @customer.attributes = { :street_address => '3003 Benham Avenue' }
    @customer.street_address.should == '3003 Benham Avenue'
  end
  
  it "should require a city" do
    @customer.should have(2).errors_on(:city)
    @customer.errors.on(:city).should include("can't be blank")
    @customer.city = 'Elkhart'
    @customer.should have(:no).errors_on(:city)
  end
  
  it "should require a city that is less than or equal to 255 characters in length" do
    long_city = ''
    0.upto(256) { |i| long_city << i.to_s  }
    @customer.city = long_city
    @customer.should have(1).error_on(:city)
    @customer.errors.on(:city).should == 'is too long (maximum is 255 characters)'
  end
  
  it "should allow city to be changed via mass-assignment" do
    @customer.city.should be_blank
    @customer.attributes = { :city => 'Elkhart' }
    @customer.city.should == 'Elkhart'
  end
  
  it "should require a state" do
    @customer.should have(2).errors_on(:state)
    @customer.errors.on(:state).should include("can't be blank")
    @customer.state = 'IN'
    @customer.should have(:no).errors_on(:state)
  end
  
  it "should require a state that is equal to 2 characters in length" do
    long_state = ''
    0.upto(2) { |i| long_state << i.to_s  }
    @customer.state = long_state
    @customer.should have(1).error_on(:state)
    @customer.errors.on(:state).should == 'is the wrong length (should be 2 characters)'
    
    short_state = 'I'
    @customer.state = short_state
    @customer.should have(1).error_on(:state)
    @customer.errors.on(:state).should == 'is the wrong length (should be 2 characters)'
  end
  
  it "should allow state to be changed via mass-assignment" do
    @customer.state.should be_blank
    @customer.attributes = { :state => 'IN' }
    @customer.state.should == 'IN'
  end
  
  it "should require a postal code" do
    @customer.should have(2).errors_on(:postal_code)
    @customer.errors.on(:postal_code).should include("can't be blank")
    @customer.postal_code = '46517'
    @customer.should have(:no).errors_on(:postal_code)
  end
  
  it "should require a postal code that is 5 to 10 characters in length" do
    long_postal_code = ''
    0.upto(11) { |i| long_postal_code << i.to_s  }
    @customer.postal_code = long_postal_code
    @customer.should have(2).errors_on(:postal_code)
    @customer.errors.on(:postal_code).should include('is too long (maximum is 10 characters)')
    
    short_postal_code = '4561'
    @customer.postal_code = short_postal_code
    @customer.should have(2).errors_on(:postal_code)
    @customer.errors.on(:postal_code).should include('is too short (minimum is 5 characters)')
  end
  
  it "should require that a postal code conform to the US format" do
    @customer.postal_code = 'abcde'
    @customer.should have(1).error_on(:postal_code)
    @customer.errors.on(:postal_code).should == 'must be at least 5 digits (e.g., <em>94044</em>)'
    
    @customer.postal_code = '46517-12'
    @customer.should have(1).error_on(:postal_code)
    @customer.errors.on(:postal_code).should == 'must be at least 5 digits (e.g., <em>94044</em>)'
    
    @customer.postal_code = '46517'
    @customer.should have(:no).errors_on(:postal_code)
    
    @customer.postal_code = '46517-1234'
    @customer.should have(:no).errors_on(:postal_code)
  end
  
  it "should allow postal code to be changed via mass-assignment" do
    @customer.postal_code.should be_blank
    @customer.attributes = { :postal_code => '46517' }
    @customer.postal_code.should == '46517'
  end
  
  it "should require a phone number" do
    @customer.should have(2).errors_on(:phone_number)
    @customer.errors.on(:phone_number).should include("can't be blank")
    @customer.phone_number = '574 304 1187'
    @customer.should have(:no).errors_on(:phone_number)
  end
  
  it "should require a phone number that is less than or equal to 255 characters in length" do
    long_phone_number = ''
    0.upto(256) { |i| long_phone_number << i.to_s  }
    @customer.phone_number = long_phone_number
    @customer.should have(1).error_on(:phone_number)
    @customer.errors.on(:phone_number).should == 'is too long (maximum is 255 characters)'
  end
  
  it "should allow phone_number to be changed via mass-assignment" do
    @customer.phone_number.should be_blank
    @customer.attributes = { :phone_number => '574 304 1187' }
    @customer.phone_number.should == '574 304 1187'
  end
  
  describe "#set_address_from" do    
    describe "when profile is blank" do
      it "should do nothing" do
        @customer.set_address_from(@profile)
        @customer.street_address.should be_blank
        @customer.city.should be_blank
        @customer.state.should be_blank
        @customer.postal_code.should be_blank
      end
    end
    
    describe "when profile is not blank" do
      before(:each) do
        @profile = mock_model(Profile)
        @profile.should_receive(:street_address).and_return('3003 Benham Avenue')
        @profile.should_receive(:city).and_return('Elkhart')
        @profile.should_receive(:state).and_return('IN')
        @profile.should_receive(:postal_code).and_return('46517')
      end
      
      it "should set the customer's address from the profile" do
        @customer.set_address_from(@profile)
        @customer.street_address.should == '3003 Benham Avenue'
        @customer.city.should == 'Elkhart'
        @customer.state.should == 'IN'
        @customer.postal_code.should == '46517'
      end
    end
  end
  
  describe "#verified?" do
  #  describe "if verified_at is set" do
  #    before(:each) do
  #      @customer.verified_at = Time.now.utc
  #    end
      
  #    it "should return true" do
  #      @customer.verified?.should be(true)
  #    end
  #  end
    
  #  describe "if verified_at is blank" do
  #    it "should return false" do
  #      @customer.verified?.should be(false)
  #    end
  #  end
  
    it "should return true" do
      @customer.verified?.should be(true)
    end
  end
  
  describe "#verifying_email?" do
  #  describe "if customer is not verified? and verification_code is set" do
  #    before(:each) do
  #      @customer.verification_code = '12345'
  #    end
      
  #    it "should return true" do
  #      @customer.verifying_email?.should be(true)
  #    end
  #  end
    
  #  describe "if customer is verified?" do
  #    before(:each) do
  #      @customer.verified_at = Time.now.utc
  #    end
      
  #    it "should return false" do
  #      @customer.verifying_email?.should be(false)
  #    end
  #  end
    
  #  describe "if customer is not verified? but verification_code is blank" do
  #    it "should return false" do
  #      @customer.verifying_email?.should be(false)
  #    end
  #  end
  
    it "should return false" do
      @customer.verifying_email?.should be(false)
    end
  end
  
#  describe "#verify!" do
#    it "should set verified_at to Time.now.utc" do
#      @customer.stub!(:save!)
#      @customer.verify!
#      @customer.verified_at.should_not be_blank
#    end
    
#    it "should save! the customer" do
#      @customer.should_receive(:save!)
#      @customer.verify!
#    end
#  end
end