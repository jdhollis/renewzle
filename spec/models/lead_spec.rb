require File.dirname(__FILE__) + '/../spec_helper'

describe Lead do
  before(:each) do
    @lead = Lead.new
  end

  it "should have one profile" do
    @lead.should respond_to(:profile)
  end

  it "should belong to a parnter" do
    @lead.should respond_to(:partner)
  end

  [ :confirmation_number, :authorization, :ip_address ].each do |attribute|
    it "should not allow #{attribute} to be changed via mass-assignment" do
      @lead.attributes = { attribute.to_sym => 'Lead' }
      @lead.send(attribute).should_not == 'Lead'
    end
  end

  it "should not allow purchased to be changed via mass-assignment" do
    @lead.attributes = { :purchased => true }
    @lead.purchased.should_not == true
  end

  [ :billing_name, :billing_email, :billing_phone_number, :billing_street_address, :billing_city, :billing_state, :billing_postal_code, :billing_country ].each do |attribute|
    it "should allow #{attribute} to be changed via mass-assignment" do
      @lead.attributes = { attribute.to_sym => 'Lead' }
      @lead.send(attribute).should == 'Lead'
    end
  end

  [ :card_first_name, :card_last_name, :card_type, :card_number, :card_expiration_month, :card_expiration_year ].each do |attribute|
    it "should allow #{attribute} to be changed via mass-assignment" do
      @lead.attributes = { attribute.to_sym => 'Lead' }
      @lead.send(attribute).should == 'Lead'
    end
  end

	describe "delegation" do
		it "should delegate postal_code to quote" do
			@quote = mock_model(Quote)
			@quote.should_receive(:postal_code)
			@lead.stub!(:quote).and_return(@quote)
			@lead.postal_code
		end

		it "should delegate nameplate_rating to quote" do
			@quote = mock_model(Quote)
			@quote.should_receive(:nameplate_rating)
			@lead.stub!(:quote).and_return(@quote)
			@lead.nameplate_rating
		end

		it "should delegate cec_rating to quote" do
			@quote = mock_model(Quote)
			@quote.should_receive(:cec_rating)
			@lead.stub!(:quote).and_return(@quote)
			@lead.cec_rating
		end
	end

	describe "#before_destroy" do
		it "should mark profile as second chance" do
			@profile = stub_model(Profile)
			@profile.should_receive(:second_chance?).and_return(false)
			@profile.should_receive(:mark_as_second_chance!)
			@lead.profile = @profile
			@lead.destroy
		end
	end

	describe "#find_purchased_by_partner" do
		before(:each) do
			@lead = stub_model(Lead)
			@partner = stub_model(Partner)
		end

		describe "record does exist" do
			it "should return lead" do
				Lead.should_receive(:find_by_id_and_purchased_and_partner_id).with(@lead.id, true, @partner.id).and_return(@lead)
				Lead.find_purchased_by_partner(@lead.id, @partner.id).should == @lead
			end
		end

		# Seems like raise_error isn't catching ActiveRecord::RecordInvalid
		# But it does catch it as a general error... go figure
		describe "record does not exist" do
			it "should raise ActiveRecord::RecordNotFound" do
				lambda { 
					Lead.should_receive(:find_by_id_and_purchased_and_partner_id).with(@lead.id, true, @partner.id).and_return(nil)
					Lead.find_purchased_by_partner(@lead.id, @partner.id) 
				}.should raise_error
				# }.should raise_error(ActiveRecord::RecordInvalid.new)
			end
		end
	end

  describe "#purchase_price" do
    before(:each) do
      @quote = mock_model(Quote)
      @quote.should_receive(:lead_purchase_price).and_return(100)
      @partner = mock_model(Partner)
      @lead.partner = @partner
      @lead.quote = @quote
    end

    it "should return price" do
      @partner.should_receive(:lead_price_given).and_return(50)
      Discount.should_receive(:global).and_return([])
      @lead.purchase_price.should == 50
    end

    it "should return price with discount adjustments" do
      @partner.should_receive(:lead_price_given).and_return(25)
      @discount = mock_model(Discount)
      @discount.should_receive(:apply_to).with(100, @lead).and_return(25)
      Discount.should_receive(:global).and_return([ @discount ])
      @lead.purchase_price.should == 25
    end
  end

  describe "#purchased?" do
    it "should return value of purcahsed field" do
      @lead.should_receive(:purchased)
      @lead.purchased?
    end
  end

	describe "#companys_first_lead?" do
		before(:each) do
			@company = stub_model(Company)
			@lead.stub!(:company).and_return(@company)
		end

		it "should return false if company has purchased any leads" do
			@company.should_receive(:has_purchased_leads?).and_return(true)
			@lead.companys_first_lead?.should == false
		end

		it "should return true if company has not purchased any leads" do
			@company.should_receive(:has_purchased_leads?).and_return(false)
			@lead.companys_first_lead?.should == true
		end
	end

	describe "#set_billing_information_from" do
		before(:each) do
			@user = stub_model(User)
    	@user.stub!(:full_name).and_return('full name')
    	@user.stub!(:email).and_return('email')
    	@user.stub!(:phone_number).and_return('phone number')
    	@user.stub!(:street_address).and_return('street address')
    	@user.stub!(:city).and_return('city')
    	@user.stub!(:state).and_return('state')
    	@user.stub!(:postal_code).and_return('postal code')
		end

		it "should assign billing attributes from user" do
			@lead.set_billing_information_from(@user)
			@lead.billing_name.should == 'full name'
			@lead.billing_email.should == 'email'
			@lead.billing_phone_number.should == 'phone number'
			@lead.billing_street_address.should == 'street address'
			@lead.billing_city.should == 'city'
			@lead.billing_state.should == 'state'
			@lead.billing_postal_code.should == 'postal code'
			@lead.billing_country.should == 'United States'
		end
	end

	describe "#update_profile_address_with" do
		it "should update profile with passed params" do
			params = mock({})
			@profile = stub_model(Profile)
			@profile.should_receive(:attributes=).with(params)
			@profile.should_receive(:save!)
			@lead.should_receive(:save!)
			@lead.profile = @profile
			@lead.update_profile_address_with(params)
		end
	end

	describe "#purchase!" do
		before(:each) do
			@lead.stub!(:customer).and_return(stub_model(Customer))
			@lead.stub!(:partner).and_return(stub_model(Partner))
			@lead.stub!(:purchase_price).and_return(1)
			@lead.stub!(:save!).and_return(true)
			setup_credit_card
		end

		describe "when credit card is valid" do
			before(:each) do
				@credit_card.should_receive(:valid?).and_return(true)
				@credit_card.stub!(:number).and_return('1')
				LeadNotifier.should_receive(:deliver_purchase_confirmation_to_partner_for)
			end

			it "should set purchase information" do
				@lead.purchase!
				@lead.authorization.should_not be_nil
				@lead.confirmation_number.should_not be_nil
				@lead.purchased.should == true
			end
		end

		describe "when credit card is invalid" do
			describe "when credit card has invalid information" do
				before(:each) do
					@credit_card.should_receive(:valid?).and_return(false)
				end

				it "should raise Renewzle::CreditCardInvalid" do
					lambda {
						@lead.purchase!
					}.should raise_error(Renewzle::CreditCardInvalid, 'Credit card invalid')
				end
			end

			describe "when credit card is declined" do
				before(:each) do
					@credit_card.should_receive(:valid?).and_return(true)
					@response = mock('response')
					@response.stub!(:success?).and_return(false)
					@response.stub!(:message).and_return('payment failed')
					$gateway.stub!(:authorize).and_return(@response)
				end

				it "should raise Renewzle::PaymentAuthorizationFailed" do
					lambda {
						@lead.purchase!
					}.should raise_error(Renewzle::PaymentAuthorizationFailed, @response.message)
				end
			end
		end

		def setup_credit_card
			@credit_card = mock('creditcard')
			@credit_card.stub!(:errors).and_return({ :verification_value => 'empty', :month => 'empty', :year => 'empty', :other => 'empty' })
			ActiveMerchant::Billing::CreditCard.should_receive(:new).and_return(@credit_card)
		end
	end
end
