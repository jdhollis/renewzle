class Lead < ActiveRecord::Base
  acts_as_soft_deletable
  
	has_one :profile
  has_one :solution, :dependent => :destroy
	belongs_to :quote
	belongs_to :partner
  
  named_scope :recent, :order => 'created_at DESC', :limit => 20
  
  composed_of :selling_price, :class_name => 'Money', :mapping => [ %w(selling_price_cents cents), %w(selling_price_currency currency) ]
  
  validates_presence_of :quote_id

  delegate :company, :to => :partner
  delegate :city, :to => :profile
  delegate :customer, :to => :profile
  delegate :nameplate_rating, :to => :quote
  delegate :cec_rating, :to => :quote
  delegate :postal_code, :to => :quote
  delegate :total_price, :to => :quote

  attr_accessor :billing_name, :billing_email, :billing_phone_number, :billing_street_address, :billing_city, :billing_state, :billing_postal_code, :billing_country
  attr_accessor :card_first_name, :card_last_name, :card_type, :card_number, :card_expiration_month, :card_expiration_year, :card_verification

  attr_protected :confirmation_number, :authorization, :ip_address, :purchased

  before_destroy do |record|
    record.profile.mark_as_second_chance! unless record.profile.second_chance?
  end

  def self.find_purchased_by_partner(lead_id, partner_id)
    unless lead = Lead.find_by_id_and_purchased_and_partner_id(lead_id, true, partner_id)
      raise ActiveRecord::RecordNotFound
    end
    
    return lead
  end

  def purchased?
    purchased
  end

  def purchase_price
    price = quote.lead_purchase_price
    global_discounts.each { |discount| price = discount.apply_to(price, self) }
    partner.lead_price_given(price, self)
  end

  def companys_first_lead?
    !company.has_purchased_leads?
  end

  def set_billing_information_from(user)
    self.billing_name = user.full_name
    self.billing_email = user.email
    self.billing_phone_number = user.phone_number
    self.billing_street_address = user.street_address
    self.billing_city = user.city
    self.billing_state = user.state
    self.billing_postal_code = user.postal_code
    self.billing_country = 'United States'
  end

  def update_profile_address_with(params)
	  profile.attributes = params
    transaction do
      profile.save!
      save!
    end
  end

	def purchase!
		credit_card = ActiveMerchant::Billing::CreditCard.new(
			:first_name => card_first_name, 
			:last_name => card_last_name,
			:type => card_type,
			:number => card_number,
			:verification_value	=> card_verification,
			:month => card_expiration_month,
			:year => card_expiration_year
		)
		unless credit_card.valid?
      credit_card.errors.each do |key, message|
        case key
        when :verification_value
          errors.add(:card_verification, message)
        when :month
          errors.add(:card_expiration_month, message)
        when :year
          errors.add(:card_expiration_year, message)
        else
          errors.add("card_#{key}".to_sym, message)
        end
      end
      raise Renewzle::CreditCardInvalid, 'Credit card invalid'
    end
		
		options = {
			:name => billing_name,
			:email => billing_email,
			:phone => billing_phone_number,
			:ip_address	=> ip_address,
			:card_code => card_verification,
			:billing_address => {
				:name => billing_name,
				:address1 => billing_street_address,
				:city => billing_city,
				:state => billing_state,
				:zip => billing_postal_code,
				:country => billing_country,
				:phone => billing_phone_number
			}
		}

    amount = purchase_price.to_money  # discounts aren't calculated using Money (for some reason)

		response = $gateway.authorize(amount, credit_card, options)
    raise Renewzle::PaymentAuthorizationFailed, response.message unless response.success?
    
		$gateway.capture(amount, response.authorization)
		self.authorization = '1234' #response.authorization
		self.purchased = true
		self.selling_price = amount
		self.confirmation_number = Time.now.strftime("%Y%m%d") + "-" + Digest::MD5.hexdigest(authorization).gsub(/[a-z]/, '')[0..8]
		save!
		
		LeadNotifier.deliver_purchase_confirmation_to_partner_for(self)
	end

private

  attr_accessor :cached_global_discounts

  def global_discounts
    if cached_global_discounts.blank?
      self.cached_global_discounts = Discount.global
    end
    cached_global_discounts
  end
end
