require File.dirname(__FILE__) + '/../spec_helper'

describe Profile do
  before(:each) do
    @profile = Profile.new
    @engine = mock("calculation engine", :nameplate_rating => '10')
    CalculationEngine.stub!(:new).and_return(@engine)
  end
  
  it "should belong to a customer" do
    @profile.should respond_to(:customer)
  end
  
  it "should belong to a lead" do
    @profile.should respond_to(:lead)
  end
  
  it "should belong to a utility" do
    @profile.should respond_to(:utility)
  end
	
	
  #
  # Sizing
  #
	
  it "should delegate :nameplate_rating to :calculation_engine" do
    @engine.should_receive(:nameplate_rating)
    @profile.nameplate_rating
  end
  
  it "should delegate :cec_rating to :calculation_engine" do
    @engine.should_receive(:cec_rating)
    @profile.cec_rating
  end
  
  it "should delegate :cec_rating_without_derate to :calculation_engine" do
    @engine.should_receive(:cec_rating_without_derate)
    @profile.cec_rating_without_derate
  end
  
  it "should delegate :monthly_cost_optimal_offset to :calculation_engine" do
    @engine.should_receive(:monthly_cost_optimal_offset)
    @profile.monthly_cost_optimal_offset
  end
  
  
  
  describe "#find_unowned" do
    describe "when given a valid id for a profile not associated with a customer" do
      it "should return the profile" do
        Profile.should_receive(:find_by_id_and_customer_id).with('1', nil).and_return(@profile)
        Profile.find_unowned('1').should be(@profile)
      end
    end
    
    describe "when given an id for a non-existant profile or a profile already associated with a customer" do
      it "should return nil" do
        Profile.find_unowned('1').should be(nil)
      end
    end
  end

  describe "#find_rfqs" do
    it "should find all by rfq and empty lead id" do
      Profile.should_receive(:find_all_by_rfq_and_lead_id_and_approved).with(true, nil, true)
      Profile.find_rfqs
    end
  end
  
  describe "#set_address_from" do    
    describe "when profile is blank" do
      it "should do nothing" do
        @profile.set_address_from(@customer)
        @profile.street_address.should be_blank
        @profile.city.should be_blank
        @profile.state.should be_blank
        @profile.postal_code.should be_blank
      end
    end
    
    describe "when profile is not blank" do
      before(:each) do
        @customer = mock_model(Customer)
        @customer.should_receive(:street_address).and_return('3003 Benham Avenue')
        @customer.should_receive(:city).and_return('Elkhart')
        @customer.should_receive(:state).and_return('IN')
        @customer.should_receive(:postal_code).and_return('46517')
      end
      
      it "should set the customer's address from the profile" do
        @profile.set_address_from(@customer)
        @profile.street_address.should == '3003 Benham Avenue'
        @profile.city.should == 'Elkhart'
        @profile.state.should == 'IN'
        @profile.postal_code.should == '46517'
      end
    end
  end
  
  describe "#update_from" do
    before(:each) do
      @params = { 'id' => '1' }
    end
    
    it "should set attributes to params" do
      @profile.should_receive(:attributes=).with(@params)
      @profile.stub!(:save!)
      @profile.update_from(@params)
    end
    
    it "should save! the profile" do
      @profile.stub!(:attributes=)
      @profile.should_receive(:save!)
      @profile.update_from(@params)
    end
  end
	
  describe "#is_owned?" do
    describe "when customer is blank?" do
      it "should return false" do
        @profile.is_owned?.should be(false)
      end
    end
    
    describe "when customer is set" do
      before(:each) do
        @profile.customer = mock_model(Customer)
      end
      
      it "should return true" do
        @profile.is_owned?.should be(true)
      end
    end
  end
  
  describe "#purchased_as_lead?" do
    describe "when lead is blank" do
      it "should return false" do
        @profile.purchased_as_lead?.should be(false)
      end
    end
    
    describe "when lead is not blank but lead has not been purchased?" do
      before(:each) do
        @lead = mock_model(Lead)
        @lead.should_receive(:purchased?).and_return(false)
        @profile.lead = @lead
      end
      
      it "should return false" do
        @profile.purchased_as_lead?.should be(false)
      end
    end
    
    describe "when lead is not blank and lead has been purchased?" do
      before(:each) do
        @lead = mock_model(Lead)
        @lead.should_receive(:purchased?).and_return(true)
        @profile.lead = @lead
      end
      
      it "should return true" do
        @profile.purchased_as_lead?.should be(true)
      end
    end
  end

  describe "#waiting_approval?" do
    it "should return false if rfq is false" do
      @profile.rfq = false
      @profile.waiting_approval?.should == false
    end

    it "should return false if approved is not nil?" do
      @profile.approved = false
      @profile.waiting_approval?.should == false
    end

    it "should return true if rfq is true and approved is nil?" do
      @profile.rfq = true
      @profile.approved = nil
      @profile.waiting_approval?.should == true
    end
  end
  
  describe "#getting_started?" do
    describe "when postal_code_invalid?" do
      it "should return true" do
        @profile.getting_started?.should be(true)
      end
    end
    
    describe "when utility_invalid?" do
      before(:each) do
        @profile.postal_code = '94044'
        @profile.state = 'CA'
      end
      
      it "should return true" do
        @profile.getting_started?.should be(true)
      end
    end
    
    describe "when tariff_invalid?" do
      before(:each) do
        @profile.postal_code = '94044'
        @profile.state = 'CA'
        @profile.utility = mock_model(Utility)
        @tariff_1 = mock_model(Tariff)
        @tariff_2 = mock_model(Tariff)
        @profile.utility.should_receive(:tariffs).and_return([ @tariff_1, @tariff_2 ])
      end
      
      it "should return true" do
        @profile.getting_started?.should be(true)
      end
    end
    
    describe "when usage_invalid?" do
      before(:each) do
        @profile.postal_code = '94044'
        @profile.state = 'CA'
        @profile.utility = mock_model(Utility)
        @tariff = mock_model(Tariff)
        @profile.utility.should_receive(:tariffs).and_return([ @tariff ])
        @profile.region = 'region'
      end
      
      it "should return true" do
        @profile.getting_started?.should be(true)
      end
    end
    
    describe "when postal_code, utility, tariff, and usage are all valid" do
      before(:each) do
        @profile.postal_code = '94044'
        @profile.state = 'CA'
        @profile.utility = mock_model(Utility)
        @tariff = mock_model(Tariff)
        @profile.utility.should_receive(:tariffs).and_return([ @tariff ])
        @profile.region = 'region'
        @profile.average_monthly_bill = 250.0
      end
      
      it "should return false" do
        @profile.getting_started?.should be(false)
      end
    end
  end
  
  describe "#postal_code_invalid?" do
    describe "when postal_code is blank" do
      it "should return true" do
        @profile.postal_code_invalid?.should be(true)
      end
    end
    
    describe "when postal_code does not match /^[0-9]{5}$/" do
      before(:each) do
        @profile.postal_code = 'invalid'
      end
      
      it "should return true" do
        @profile.postal_code_invalid?.should be(true)
      end
    end
    
    describe "when postal_code is not in California" do
      before(:each) do
        @profile.postal_code = '46517'
        @profile.state = 'IN'
      end
      
      it "should return true" do
        @profile.postal_code_invalid?.should be(true)
      end
    end
    
    describe "when postal_code is not blank, matches /^[0-9]{5}$/, and is in California" do
      before(:each) do
        @profile.postal_code = '94044'
        @profile.state = 'CA'
      end
      
      it "should return false" do
        @profile.postal_code_invalid?.should be(false)
      end
    end
  end
  
  describe "#utility_invalid?" do
    describe "when utility is blank" do
      it "should return true" do
        @profile.utility_invalid?.should be(true)
      end
    end
    
    describe "when utility is set" do
      before(:each) do
        @profile.utility = mock_model(Utility)
      end
      
      it "should return false" do
        @profile.utility_invalid?.should be(false)
      end
    end
  end
  
  describe "#tariff_invalid?" do
    describe "when there is 1 tariff or less in tariffs" do
      before(:each) do
        @utility = mock_model(Utility)
        @tariff = mock_model(Tariff)
        @utility.should_receive(:tariffs).and_return([ @tariff ])
        @profile.utility = @utility
      end
      
      it "should return false" do
        @profile.tariff_invalid?.should be(false)
      end
    end
    
    describe "when there is more than 1 tariff in tariffs and region is not blank" do
      before(:each) do
        @utility = mock_model(Utility)
        @tariff_1 = mock_model(Tariff)
        @tariff_2 = mock_model(Tariff)
        @utility.should_receive(:tariffs).and_return([ @tariff_1, @tariff_2 ])
        @profile.utility = @utility
        @profile.region = 'region'
      end
      
      it "should return false" do
        @profile.tariff_invalid?.should be(false)
      end
    end
    
    describe "when there is more than 1 tariff in tariffs and region is blank" do
      before(:each) do
        @utility = mock_model(Utility)
        @tariff_1 = mock_model(Tariff)
        @tariff_2 = mock_model(Tariff)
        @utility.should_receive(:tariffs).and_return([ @tariff_1, @tariff_2 ])
        @profile.utility = @utility        
      end
      
      it "should return true" do
        @profile.tariff_invalid?.should be(true)
      end
    end
  end
  
  describe "#single_tariff?" do
    before(:each) do
      @utility = mock_model(Utility)
      @profile.utility = @utility
    end
    
    describe "when there is only 1 tariff in tariffs" do
      before(:each) do
        @tariff = mock_model(Tariff)
        @utility.should_receive(:tariffs).and_return([ @tariff ])
      end
      
      it "should return true" do
        @profile.single_tariff?.should be(true)
      end
    end
    
    describe "when there is more or less than 1 tariff in tariffs" do
      before(:each) do
        @tariff_1 = mock_model(Tariff)
        @tariff_2 = mock_model(Tariff)
        @utility.should_receive(:tariffs).and_return([ @tariff_1, @tariff_2 ])
      end
      
      it "should return false" do
        @profile.single_tariff?.should be(false)
      end
    end
  end
  
  describe "#usage_invalid?" do
    describe "when average_monthly_bill is blank" do
      it "should return true" do
        @profile.usage_invalid?.should be(true)
      end
    end
    
    describe "when average_monthly_bill is set" do
      before(:each) do
        @profile.average_monthly_bill = 250.0
      end
      
      it "should return false" do
        @profile.usage_invalid?.should be(false)
      end
    end
  end
  
  describe "#current_getting_started_field" do
    describe "when postal_code_invalid?" do
      it "should return 'postal_code'" do
        @profile.current_getting_started_field.should == 'postal_code'
      end
    end
    
    describe "when utility_invalid?" do
      before(:each) do
        @profile.postal_code = '94044'
        @profile.state = 'CA'
      end
      
      it "should return 'utility'" do
        @profile.current_getting_started_field.should == 'utility'
      end
    end
    
    describe "when tariff_invalid?" do
      before(:each) do
        @profile.postal_code = '94044'
        @profile.state = 'CA'
        @profile.utility = mock_model(Utility)
        @tariff_1 = mock_model(Tariff)
        @tariff_2 = mock_model(Tariff)
        @profile.utility.should_receive(:tariffs).and_return([ @tariff_1, @tariff_2 ])
      end
      
      it "should return 'region'" do
        @profile.current_getting_started_field.should == 'region'
      end
    end
    
    describe "when usage_invalid?" do
      before(:each) do
        @profile.postal_code = '94044'
        @profile.state = 'CA'
        @profile.utility = mock_model(Utility)
        @tariff_1 = mock_model(Tariff)
        @tariff_2 = mock_model(Tariff)
        @profile.utility.should_receive(:tariffs).and_return([ @tariff_1, @tariff_2 ])
        @profile.region = 'region'
      end
      
      it "should return 'usage'" do
        @profile.current_getting_started_field.should == 'usage'
      end
    end
  end
  
  describe "#last_completed_getting_started_field" do
    describe "when postal_code_invalid?" do
      it "should return nil" do
        @profile.last_completed_getting_started_field.should be_nil
      end
    end
    
    describe "when utility_invalid?" do
      before(:each) do
        @profile.postal_code = '94044'
        @profile.state = 'CA'
      end
      
      it "should return 'postal_code'" do
        @profile.last_completed_getting_started_field.should == 'postal_code'
      end
    end
    
    describe "when tariff_invalid?" do
      before(:each) do
        @profile.postal_code = '94044'
        @profile.state = 'CA'
        @profile.utility = mock_model(Utility)
        @tariff_1 = mock_model(Tariff)
        @tariff_2 = mock_model(Tariff)
        @profile.utility.should_receive(:tariffs).and_return([ @tariff_1, @tariff_2 ])
      end
      
      it "should return 'utility'" do
        @profile.last_completed_getting_started_field.should == 'utility'
      end
    end
    
    describe "when usage_invalid?" do
      before(:each) do
        @profile.postal_code = '94044'
        @profile.state = 'CA'
        @profile.utility = mock_model(Utility)
      end
      
      describe "if region is blank?" do
        before(:each) do
          @profile.utility.should_receive(:tariffs).and_return([])
        end
        
        it "should return 'utility'" do
          @profile.last_completed_getting_started_field.should == 'utility'
        end
      end
      
      describe "if region is not blank?" do
        before(:each) do
          @tariff_1 = mock_model(Tariff)
          @tariff_2 = mock_model(Tariff)
          @profile.utility.should_receive(:tariffs).and_return([ @tariff_1, @tariff_2 ])
          @profile.region = 'region'
        end
        
        it "should return 'region'" do
          @profile.last_completed_getting_started_field.should == 'region'
        end
      end
    end
  end
  
  describe "#next_getting_started_fields" do
    describe "when last completed field is 'postal_code'" do
      before(:each) do
        @profile.postal_code = '94044'
        @profile.state = 'CA'
      end
      
      it "should include 'utility'" do
        @profile.next_getting_started_fields.should include('utility')
      end
    end
    
    describe "when last completed field is 'utility'" do
      before(:each) do
        @profile.postal_code = '94044'
        @profile.state = 'CA'
        @profile.utility = mock_model(Utility)
      end
      
      describe "and there is only 1 tariff" do
        before(:each) do
          @tariff = mock_model(Tariff)
          @profile.utility.stub!(:tariffs).and_return([ @tariff ])
        end
        
        it "should include 'usage'" do
          @profile.next_getting_started_fields.should include('usage')
        end
      end
      
      describe "and there is more than 1 tariff" do
        before(:each) do
          @tariff_1 = mock_model(Tariff)
          @tariff_2 = mock_model(Tariff)
          @profile.utility.stub!(:tariffs).and_return([ @tariff_1, @tariff_2 ])
        end
        
        it "should include 'region'" do
          @profile.next_getting_started_fields.should include('region')
        end
      end
    end
    
    describe "when last completed field is anything other than 'postal_code' or 'utility'" do
      before(:each) do
        @profile.postal_code = '94044'
        @profile.state = 'CA'
        @profile.utility = mock_model(Utility)
        @tariff_1 = mock_model(Tariff)
        @tariff_2 = mock_model(Tariff)
        @profile.utility.stub!(:tariffs).and_return([ @tariff_1, @tariff_2 ])
        @profile.region = 'region'
      end
      
      it "should include 'usage'" do
        @profile.next_getting_started_fields.should include('usage')
      end
    end
  end
  
  describe "#optimize_system_size!" do
    before(:each) do
      @optimal_size = 65
      @engine.should_receive(:monthly_cost_optimal_offset).and_return(@optimal_size)
    end
    
    it "should optimize the settings for the lowest monthly cost" do
      @profile.should_receive(:save!)
      @profile.optimize_system_size!
      @profile.percentage_to_offset.should == @optimal_size.percent
    end
  end
	
  describe "#tariffs" do
    describe "when utility is set" do
      before(:each) do
        @tariffs = mock('tariffs')
        @utility = mock_model(Utility)
        @utility.should_receive(:tariffs).and_return(@tariffs)
        @profile.utility = @utility
      end
      
      it "should return utility.tariffs" do
        @profile.tariffs.should == @tariffs
      end
    end
    
    describe "when utility is not set" do
      it "should return []" do
        @profile.tariffs.should == []
      end
    end
  end

  describe "#request_quotes" do
    before(:each) do
      @profile.should_receive(:save!)
    end

    it "should set :rfq to true" do
      @profile.should_receive(:rfq=).with(true)
      @profile.request_quotes!
    end
  end
  
  describe "#approve!" do
    before(:each) do
      @customer = stub_model(Customer)
      @profile.customer = @customer
      @profile.should_receive(:save!)
      @partner = stub_model(Partner, :email => "test@test.com")
      @profile.should_receive(:find_interested_partners).and_return([ @partner ])
    end

    it "should set :waiting_approval to true" do
      @profile.should_receive(:approved=).with(true)
      @profile.approve!
    end

#    it "should deliver a confirmation to the customer" do
#      ProfileNotifier.should_receive(:deliver_rfq_confirmation_to).with(@customer)
#      @profile.approve!
#    end
      
    it "should notify related partners of the rfq" do
      ProfileNotifier.should_receive(:deliver_rfq_notification_to_partner_for).with(@profile, @partner)
      @profile.approve!
    end
  end

  describe "#decline!" do
    it "should set :approved to false" do
      @profile.should_receive(:approved=).with(false)
      @profile.should_receive(:save!)
      @profile.decline!
    end
  end
  
  describe "#withdraw!" do
    before(:each) do
      @copied_attributes = { :customer_id => 1, :utility_id => 2, :street_address => '1652 Rosita Road', :city => 'Pacifica', :state => 'CA', :postal_code => '94044', :average_monthly_bill => 250.0, :annual_interest_rate => 0.07, :percentage_to_offset => 0.55, :loan_term => 20, :second_chance => true, :filing_status => 'Married', :income => 200000.0, :region => 'Basic Territory X', :system_performance_derate => 0.2  }
      
      @copied_attributes.each do |attr, value|
        @profile.send("#{attr}=", value)
      end
      
      @profile.approved = true
      @profile.rfq = true
      @profile.lead_id = 3
      
      @profile.save(false)
    end
    
    it "should return a near copy of the profile being withdrawn" do
      @copy = @profile.withdraw!
      
      @copied_attributes.each do |attr, value|
        @copy.send(attr).should == @profile.send(attr)
      end
      
      [ 'id', 'created_at', 'updated_at', 'approved', 'rfq', 'lead_id' ].each do |attr|
        @copy.send(attr).should_not == @profile.send(attr)
      end
    end
    
    it "should destroy itself" do
      @profile.should_receive(:destroy)
      @profile.withdraw!
    end
  end
end
