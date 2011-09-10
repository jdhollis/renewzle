class Profile < ActiveRecord::Base
  include Renewzle::Conversions
  
  acts_as_soft_deletable
  
  belongs_to :customer
  belongs_to :utility
  belongs_to :solar_rating
  belongs_to :federal_income_tax_bracket
  belongs_to :state_income_tax_bracket
  belongs_to :lead
  belongs_to :geo_region
  
  has_many :quotes, :order => 'created_at ASC', :dependent => :destroy
  
  named_scope :recent, :order => 'created_at DESC', :limit => 20
  named_scope :waiting_approval, :conditions => [ 'rfq = ? AND approved IS NULL', true ], :order => 'updated_at DESC'

  attr_accessible :street_address, :city, :state, :postal_code, :utility_id, :region, :raw_average_monthly_bill, :raw_annual_interest_rate, :raw_percentage_to_offset, :loan_term, :filing_status, :raw_income, :raw_system_performance_derate, :validate_postal_code
  
  
  #
  # Validations
  #
  
  validates_presence_of :street_address, :if => Proc.new { |record| record.ready_to_accept_quote? }
  validates_length_of :street_address, :maximum => 255, :allow_nil => true
  
  validates_presence_of :city, :if => Proc.new { |record| record.ready_to_accept_quote? }
  validates_length_of :city, :maximum => 255, :allow_nil => true
  
  validates_presence_of :state, :if => Proc.new { |record| record.ready_to_accept_quote? }
  validates_length_of :state, :maximum => 2, :allow_nil => true
  
  validates_presence_of :postal_code, :if => Proc.new { |record| record.must_validate_postal_code? || record.ready_to_accept_quote? }
  validates_format_of :postal_code, :with => /^[0-9]{5}$/, :message => 'must be 5 digits (e.g., <em>94044</em>)', :if => Proc.new { |record| !record.postal_code.blank? && record.must_validate_postal_code? }
  
  validate :has_california_postal_code
  
  validates_presence_of :utility_id, :if => Proc.new { |record| record.must_validate_utility? }
  validates_presence_of :region, :if => Proc.new { |record| record.must_validate_region? }
  validates_presence_of :average_monthly_bill, :if => Proc.new { |record| record.must_validate_usage? }


  #
  # Callbacks
  #
  
  before_validation_on_create do |record|
    record.geocode
    record.set_federal_income_tax_bracket
  end
  
  
  #
  # Initialization
  #
  
  def geocode
#    if ENV['RAILS_ENV'] == 'production'
      self.city = nil
      self.state = nil
      self.geo_region = nil
    
      geoloc = GeoKit::Geocoders::MultiGeocoder.geocode(address)
      if geoloc.success
        [ :city, :state ].each { |attribute| self.send("#{attribute}=", geoloc.send(attribute)) }
        self.solar_rating = SolarRating.find_closest(:origin => geoloc)
#        self.geo_region = GeoRegion.store_with_state(self.state, geoloc.county)
        _city = GeoCity.find_by_postal_code(geoloc.zip)
        self.geo_region = _city.geo_region if _city
        set_state_income_tax_bracket
      end
#    else
#      self.city = "Pacifica"
#      self.state = "CA"
#      self.solar_rating = SolarRating.find(55240) # postal code 94044
#      _city = GeoCity.find_by_postal_code(94044)
#      self.geo_region = _city.geo_region if _city
#      set_state_income_tax_bracket
#    end
  end
  
  def set_federal_income_tax_bracket
    self.federal_income_tax_bracket = FederalIncomeTaxBracket.find_by_filing_status_for_income(filing_status, income)
  end
  
  
  #
  # Sizing
  #
  
  delegate :nameplate_rating, :to => :calculation_engine
  delegate :cec_rating, :to => :calculation_engine
  delegate :cec_rating_without_derate, :to => :calculation_engine
  
  delegate :monthly_cost_optimal_offset, :to => :calculation_engine
  
  
  #
  # System cost
  #
  
  delegate :system_cost, :to => :calculation_engine
  delegate :installation_cost, :to => :calculation_engine
  delegate :project_cost, :to => :calculation_engine
  delegate :total_price, :to => :calculation_engine
  delegate :sales_tax, :to => :calculation_engine
  delegate :net_system_cost, :to => :calculation_engine
  
  delegate :average_dollar_cost_per_nameplate_watt, :to => :calculation_engine
  delegate :average_dollar_cost_per_cec_watt, :to => :calculation_engine
  delegate :average_dollar_system_cost_per_nameplate_watt, :to => :calculation_engine
  delegate :average_dollar_installation_cost_per_nameplate_watt, :to => :calculation_engine
  delegate :average_dollar_system_cost_per_cec_watt, :to => :calculation_engine
  delegate :average_dollar_installation_cost_per_cec_watt, :to => :calculation_engine
  
  
  #
  # Annual usage, output, and bill calculations
  #
  
  delegate :annual_usage, :to => :calculation_engine
  delegate :annual_output, :to => :calculation_engine
  delegate :annual_usage_after, :to => :calculation_engine
  delegate :annual_bill, :to => :calculation_engine
  delegate :annual_bill_after, :to => :calculation_engine
  
  
  #
  # Monthly usage, output, and bill calculations
  #
  
  delegate :average_monthly_cost_before, :to => :calculation_engine
  delegate :average_monthly_bill_after, :to => :calculation_engine
  delegate :average_monthly_cost_after, :to => :calculation_engine
  
  delegate :usage_without_solar_by_month, :to => :calculation_engine
  delegate :usage_with_solar_by_month, :to => :calculation_engine
  
  delegate :bill_without_solar_by_month, :to => :calculation_engine
  delegate :bill_with_solar_by_month, :to => :calculation_engine
  
  
  #
  # Savings
  #
  
  delegate :first_year_savings, :to => :calculation_engine
  delegate :lifetime_savings, :to => :calculation_engine
  
  delegate :average_monthly_savings, :to => :calculation_engine
  
  
  #
  # Loan
  #
  
  def number_of_monthly_loan_payments
    loan_term.blank? ? 0 : loan_term * 12
  end

  def monthly_interest_rate
    annual_interest_rate.blank? ? 0.0 : annual_interest_rate / 12.0
  end
  
  delegate :loan_principal, :to => :calculation_engine
  delegate :monthly_loan_payment, :to => :calculation_engine
  
  
  #
  # Taxes
  #
  
  delegate :monthly_federal_tax_effect, :to => :calculation_engine
  delegate :monthly_state_tax_effect, :to => :calculation_engine
  delegate :monthly_tax_effect, :to => :calculation_engine


  #
  # Incentives
  #
  
  def federal_incentives
    self.cached_federal_incentives = Incentive.federal_incentives if cached_federal_incentives.nil?
    cached_federal_incentives
  end
  
  def state_and_local_incentives
    city_incentives + state_incentives + utility_incentives
  end
  
  delegate :total_value_of_federal_incentives, :to => :calculation_engine
  delegate :total_value_of_state_and_local_incentives, :to => :calculation_engine
  delegate :increase_in_home_value, :to => :calculation_engine

  
  #
  # Charting
  #
  
  delegate :monthly_electric_cost_by_offset, :to => :calculation_engine
  delegate :annual_cost_before_and_after, :to => :calculation_engine
  delegate :cumulative_annual_savings, :to => :calculation_engine
  
  
  #
  # Emissions
  #
  
  def utility_source_mix
    utility.blank? ? {} : utility.source_mix
  end
  
  delegate :average_monthly_co2_emissions_before, :to => :calculation_engine
  delegate :average_monthly_co2_emissions_after, :to => :calculation_engine
  
  delegate :annual_co2_emissions_before, :to => :calculation_engine
  delegate :annual_co2_emissions_after, :to => :calculation_engine
  
  delegate :annual_so2_emissions_before, :to => :calculation_engine
  delegate :annual_so2_emissions_after, :to => :calculation_engine
  
  delegate :annual_nox_emissions_before, :to => :calculation_engine
  delegate :annual_nox_emissions_after, :to => :calculation_engine
  
  delegate :annual_mercury_emissions_before, :to => :calculation_engine
  delegate :annual_mercury_emissions_after, :to => :calculation_engine
  
  
  #
  # Comparables
  #
  
  delegate :monthly_trees_planted_before, :to => :calculation_engine
  delegate :monthly_trees_planted_after, :to => :calculation_engine
  
  delegate :monthly_cars_removed_before, :to => :calculation_engine
  delegate :monthly_cars_removed_after, :to => :calculation_engine
  
  
  #
  # Miscellaneous finders
  #
  
  def self.find_all_unowned
		Profile.find_by_customer_id(nil)
	end
  
  def self.find_rfqs
    find_all_by_rfq_and_lead_id_and_approved(true, nil, true, :order => 'updated_at DESC')
  end
  
  def self.find_unowned(profile_id)
    find_by_id_and_customer_id(profile_id, nil)
  end
  
  def self.find_for_quote(profile_id)
    unless profile = find_by_id_and_rfq(profile_id, true)
      raise ActiveRecord::RecordNotFound
    end
    
    return profile
  end
  
  def find_nearest_utilities
    Utility.find_all_by_state(state, :order => 'name ASC')
  end
  
  def find_interested_partners
    interested_partners = Array.new
    geo_region.companies.each do |company| 
      interested_partners += company.partners
    end
  
    claimed_companies = Company.find_all_by_claimed(true)
    all_california_companies = claimed_companies.collect { |c| c if c.geo_regions.blank? }.compact
    all_california_companies.each do |company|
      interested_partners += company.partners
    end
    
    return interested_partners
  end
  
  
  #
  # Controller helpers
  #
  
	def set_address_from(customer)
    unless customer.blank?
      self.street_address = customer.street_address
      self.city = customer.city
      self.state = customer.state
      self.postal_code = customer.postal_code
    end
  end
  
  def request_quotes!
    self.rfq = true
    set_address_from(customer)
    #if ENV['RAILS_ENV'] == 'production'
      geoloc = GeoKit::Geocoders::MultiGeocoder.geocode(address)
      if geoloc.success
        self.solar_rating = SolarRating.find_closest(:origin => geoloc)
      end
    #end
    save!
  end

  def approve!
    self.approved = true
    save!

    #ProfileNotifier.deliver_rfq_confirmation_to(customer)
    
    partners = find_interested_partners
    partners.each do |partner|
      ProfileNotifier.deliver_rfq_notification_to_partner_for(self, partner)
    end
  end

  def decline!
    self.approved = false
    save!
  end
  
  def withdraw!
    Profile.transaction do
      skip = [ 'id', 'created_at', 'updated_at', 'approved', 'rfq', 'lead_id' ]
      copy = Profile.new
      self.attributes.keys.each do |key|
        next if skip.include?(key)
        copy.send("#{key}=", self.send(key))
      end
      copy.save!
      
      self.destroy  # this will take care of the associated quotes as well
      
      return copy
    end
  end
  
  def update_from(params)
    profile_params = params.blank? ? {} : params
    
    must_geocode = false
    if profile_params.has_key?('postal_code')
      self.validate_postal_code = true
      #new_address = { :street_address => profile_params['street_address'], :city => profile_params.delete('city'), :state => profile_params.delete('state'), :postal_code => profile_params['postal_code'] }
      #must_geocode = address_has_changed?(new_address)
      must_geocode = has_changed?(:postal_code, profile_params['postal_code'])
    end
    
    if profile_params.has_key?('utility_id')
      self.validate_utility = true
      new_utility_id = profile_params['utility_id'].blank? ? nil : profile_params['utility_id'].to_i
      if has_changed?(:utility_id, new_utility_id)
        profile_params.delete('region')
        self.region = nil
      end
    end
    
    if profile_params.has_key?('region')
      self.validate_region = true
    end
    
    if profile_params.has_key?('raw_average_monthly_bill')
      self.validate_usage = true
    end
    
    self.attributes = profile_params
    
    if must_geocode
      previous_state = state
      geocode
      
      if has_changed?(:state, previous_state)
        self.utility = nil
        self.region = nil
      end
    else
      set_state_income_tax_bracket
    end
    
    set_federal_income_tax_bracket
    
    save!
  end
  
  def optimize_system_size!
    self.percentage_to_offset = monthly_cost_optimal_offset.percent
    save!
  end
  
  def mark_as_second_chance!
    self.second_chance = true
    save!
  end
  
  def current_getting_started_field
    case getting_started_stage
    when 1
      'postal_code'
    when 2
      'utility'
    when 3
      'region'
    when 4
      'usage'
    end
  end
  
  def last_completed_getting_started_field
    case getting_started_stage
    when 1
      nil
    when 2
      'postal_code'
    when 3
      'utility'
    when 4
      region.blank? ? 'utility' : 'region'
    end
  end
  
  def next_getting_started_fields
    returning(Array.new) do |next_fields|
      previous_field = last_completed_getting_started_field

      case previous_field
      when 'postal_code'
        next_fields << 'utility'
      when 'utility'
        next_fields << (single_tariff? ? 'usage' : 'region')
      else
        next_fields << 'usage'
      end
    end
  end
  
  
  #
  # View helpers
  #
  
  def prior_twelve_months
    returning(Array.new) do |prior_months|
      12.downto(1) { |n| prior_months << Date.today.months_ago(n) }
    end
  end
  
  
  #
  # Miscellaneous readers
  #
  
  def annual_solar_rating
    solar_rating.blank? ? CalculationEngine.average_national_annual_solar_rating : solar_rating.annual
  end
  
  def insolation_for(date)
    month = date.strftime('%b').downcase.to_sym
    solar_rating.send(month)
  end
  
  def total_yearly_insolation
    [ :jan, :feb, :mar, :apr, :may, :jun, :jul, :aug, :sep, :oct, :nov, :dec ].inject(0.0) do |total_insolation, month|
      total_insolation + solar_rating.send(month)
    end
  end
  
  def solar_potential
    solar_rating.blank? ? "" : solar_rating.potential
  end
  
  attr_accessor :current_offset
  def usage_offset
    if current_offset.blank?
      percentage_to_offset.blank? ? 100.percent : percentage_to_offset
    else
      current_offset
    end
  end
  
  def system_life
    loan_term.blank? || loan_term <= 0 ? CalculationEngine.average_system_life : [ loan_term, CalculationEngine.average_system_life ].max
  end
  
  def accepted_quote
    lead.blank? ? nil : lead.quote
  end
  
  def purchasing_partner
    purchased_as_lead? ? lead.partner : nil
  end
  
  def sales_tax_rate
    if cached_sales_tax_rate.nil?
      if sales_tax = SalesTax.find_by_city(city)
        self.cached_sales_tax_rate = sales_tax.rate
      else
        self.cached_sales_tax_rate = 0.0
      end
    end
    cached_sales_tax_rate
  end
  
  def marginal_federal_tax_rate
    federal_income_tax_bracket.blank? ? 0.0 : federal_income_tax_bracket.rate
  end
  
  def marginal_state_tax_rate
    state_income_tax_bracket.blank? ? 0.0 : state_income_tax_bracket.rate
  end
  
  def tariffs
    utility.blank? ? [] : utility.tariffs
  end
  
  def customer_proximity_to(partner)
    customer.distance_to(partner)
  end
  
  
  #
  # Predicates
  #
  
  def getting_started?
    postal_code_invalid? || utility_invalid? || tariff_invalid? || usage_invalid?
  end
  
  def must_validate_postal_code?
    getting_started? && validate_postal_code
  end
  
  def postal_code_invalid?
    postal_code.blank? || (postal_code =~ /^[0-9]{5}$/).blank? || state != 'CA'
  end
  
  def utility_invalid?
    utility.blank?
  end
  
  def must_validate_utility?
    getting_started? && validate_utility
  end
  
  def tariff_invalid?
    tariffs.size > 1 && region.blank?
  end
  
  def single_tariff?
    tariffs.size == 1
  end
  
  def must_validate_region?
    getting_started? && validate_region
  end
  
  def usage_invalid?
    average_monthly_bill.blank?
  end
  
  def must_validate_usage?
    validate_usage
  end
  
  def getting_started_with_postal_code?
    getting_started_stage == 1
  end
  
  def beyond_postal_code_stage?
    getting_started_stage > 1
  end
  
  def getting_started_with_utility?
    getting_started_stage == 2
  end
  
  def beyond_utility_stage?
    getting_started_stage > 2
  end
  
  def at_or_beyond_utility_stage?
    getting_started_with_utility? || beyond_utility_stage?
  end
  
  def getting_started_with_region?
    getting_started_stage == 3
  end
  
  def beyond_region_stage?
    getting_started_stage > 3
  end
  
  def at_or_beyond_region_stage?
    getting_started_with_region? || beyond_region_stage?
  end
  
  delegate :has_region_map?, :to => :utility
  
  def getting_started_with_usage?
    getting_started_stage == 4
  end
  
  def rfq?
    rfq
  end

  def has_accepted_quote?
    !lead.blank?
  end
  
  def purchased_as_lead?
    !lead.blank? && lead.purchased?
  end
  
  def waiting_for_quotes?
    rfq? && quotes.blank?
  end

  def waiting_approval?
    rfq == true && approved.nil?
  end
  
  def ready_to_accept_quote?
    rfq? && !quotes.blank?
  end
  
  def is_owned?
    !customer.blank?
  end
  
  def customer_has_not_reported_any_electricity_usage?
    average_monthly_bill.blank?
  end
  
  def ready_for_quotes?
    !postal_code.blank? && !rfq? && !utility.blank? && has_tariff? && customer_has_reported_electricity_usage?
  end
  
  def has_tariff?
    tariffs.size == 1 || (tariffs.size > 1 && !region.blank?)
  end
  
  def second_chance?
    second_chance
  end
  
  def customer_has_not_provided_enough_loan_information?
    annual_interest_rate.blank? || loan_term.blank?
  end

  def year_is_within_loan_term?(n)
    loan_term_is_set? && n > 0 && n <= (loan_term + 1)
  end

  
private

  #
  # Caching
  #
  
  attr_accessor :cached_calculation_engine
  attr_accessor :cached_sales_tax_rate
  attr_accessor :cached_federal_incentives
  attr_accessor :cached_state_incentives
  attr_accessor :cached_utility_incentives
  attr_accessor :cached_city_incentives
  
  #
  # Initialization
  #
  
  def calculation_engine
    self.cached_calculation_engine = CalculationEngine.new(self) if cached_calculation_engine.nil?
    cached_calculation_engine
  end
  
  def set_state_income_tax_bracket
    self.state_income_tax_bracket = StateIncomeTaxBracket.find_by_state_and_filing_status_for_income(state, filing_status, income)
  end
  
  
  #
  # Validations
  #
  
  attr_accessor :validate_postal_code
  attr_accessor :validate_utility
  attr_accessor :validate_region
  attr_accessor :validate_usage
  
  def has_california_postal_code
    if must_validate_postal_code? && !postal_code.blank? && state != 'CA'
      errors.add(:postal_code, 'must be in California')
    end
  end
  
  
  #
  # Incentives
  #
  
  def state_incentives
    self.cached_state_incentives = Incentive.state_incentives_for(state) if cached_state_incentives.nil?
    cached_state_incentives
  end
  
  def utility_incentives
    self.cached_utility_incentives = utility.incentives if cached_utility_incentives.nil?
    cached_utility_incentives
  end
  
  def city_incentives
    self.cached_city_incentives = Incentive.city_incentives_for(city, state) if cached_city_incentives.nil?
    cached_city_incentives
  end
  
  
  #
  # Miscellaneous readers
  #
  
  def address
    returning(GeoKit::GeoLoc.new) do |geoloc|
      geoloc.street_address = street_address
      geoloc.city = city
      geoloc.state = state
      geoloc.zip = postal_code
    end
  end
  
  def getting_started_stage
    if postal_code_invalid?
      1
    elsif utility_invalid?
      2
    elsif tariff_invalid?
      3
    elsif usage_invalid?
      4
    else
      5 # we're past it all.
    end
  end
  
  
  #
  # Miscellaneous writers
  #
  
  [ :percentage_to_offset, :annual_interest_rate ].each do |m|
    module_eval <<-"end_eval", __FILE__, (__LINE__ + 1)
      def raw_#{m.to_s}=(s)
        self.#{m.to_s} = convert_percentage_string_to_positive_float(s)
        self.#{m.to_s} = 100.percent if #{m.to_s}.blank? || #{m.to_s} > 100.percent
      end
    end_eval
  end
  
  def raw_system_performance_derate=(s)
    self.system_performance_derate = convert_percentage_string_to_positive_float(s)
    self.system_performance_derate = 50.percent if system_performance_derate > 50.percent
  end
  
  [ :average_monthly_bill, :income ].each do |m|
    module_eval <<-"end_eval", __FILE__, (__LINE__ + 1)
      def raw_#{m.to_s}=(s)
        as_f = convert_string_to_positive_float(s)
        self.#{m.to_s} = as_f > 0.0 ? as_f : nil
      end
    end_eval
  end
  
  
  #
  # Predicates
  #
  
  def customer_has_reported_electricity_usage?
    !customer_has_not_reported_any_electricity_usage?
  end
  
  def has_changed?(attribute, new_value)
    !new_value.blank? && self.send(attribute) != new_value
  end
  
  def address_has_changed?(new_address)
    changed = false
    new_address.each { |attribute, new_value| changed = has_changed?(attribute, new_value) }
    changed
  end
  
  def tax_status_has_changed?(new_status)
    changed = false
    new_status.each { |attribute, new_value| changed = has_changed?(attribute, new_value) }
    changed
  end
  
  def loan_term_is_set?
    !loan_term.blank?
  end
end
