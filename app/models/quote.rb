require 'money'

class Quote < ActiveRecord::Base
  include Renewzle::Conversions
  
  acts_as_soft_deletable
  
	belongs_to :profile
	belongs_to :partner
  belongs_to :photovoltaic_module
  belongs_to :photovoltaic_inverter
	has_one :lead, :dependent => :destroy
        
  belongs_to :company_backgrounder

  named_scope :recent, :order => 'created_at DESC', :limit => 20
  
  attr_accessible :profile_id, :partner_id, :photovoltaic_module_id, :number_of_modules, :photovoltaic_inverter_id, :number_of_inverters, :system_price, :installation_estimate, :installation_available, :will_accept_rebate_assignment, :photovoltaic_inverter_manufacturer, :partner, :raw_installation_estimate, :photovoltaic_module_manufacturer, :raw_system_price, :company_backgrounder_id
  
  
  #
  # Validations
  #
  
  validates_presence_of :profile_id
  validates_presence_of :partner_id
  validates_presence_of :photovoltaic_module_id
  validates_presence_of :number_of_modules
  validates_presence_of :photovoltaic_inverter_id
  validates_presence_of :number_of_inverters
  validates_presence_of :system_price
  validates_presence_of :installation_estimate, :if => Proc.new { |record| record.installation_available? }
  
  
  #
  # Pricing
  #
  
  def lead_purchase_price
    price = 0.0
    actual = (sprintf('%1.1f', nameplate_rating).to_f * 100).to_money

    price = actual

    minimum = 100.to_money
    maximum = 400.to_money

    if actual > maximum
      price = maximum
    elsif actual < minimum
      price = minimum
    end

    price = price * 50.percent if profile.second_chance?

    price
  end
  
  
  #
  # Templates
  #
  
  def save_as_template!
    qt = QuoteTemplate.new
    
    [ :partner, :photovoltaic_module, :number_of_modules, :photovoltaic_inverter, :number_of_inverters, :system_price, :installation_available, :installation_estimate, :will_accept_rebate_assignment, :company_backgrounder ].each do |sym|
      qt.send("#{sym}=", self.send(sym))
    end
    
    qt.save!
  end
  
  
  #
  # Sizing
  #
  
  delegate :nameplate_rating, :to => :calculation_engine
  delegate :cec_rating, :to => :calculation_engine
  delegate :cec_rating_without_derate, :to => :calculation_engine
  
  
  #
  # System cost
  #
  
  delegate :system_cost, :to => :calculation_engine
  delegate :installation_cost, :to => :calculation_engine
  delegate :project_cost, :to => :calculation_engine
  delegate :net_system_cost, :to => :calculation_engine
  delegate :total_price, :to => :calculation_engine
  delegate :cash_outlay, :to => :calculation_engine
  
  delegate :average_dollar_cost_per_nameplate_watt, :to => :calculation_engine
  delegate :average_dollar_cost_per_cec_watt, :to => :calculation_engine
  delegate :average_dollar_system_cost_per_nameplate_watt, :to => :calculation_engine
  delegate :average_dollar_installation_cost_per_nameplate_watt, :to => :calculation_engine
  delegate :average_dollar_system_cost_per_cec_watt, :to => :calculation_engine
  delegate :average_dollar_installation_cost_per_cec_watt, :to => :calculation_engine
  
  
  #
  # Annual usage, output, and bill calculations
  #
  
  delegate :annual_output, :to => :calculation_engine
  delegate :annual_usage_after, :to => :calculation_engine
  delegate :annual_bill_after, :to => :calculation_engine
  
  
  #
  # Monthly usage, output, and bill calculations
  #
  
  delegate :average_monthly_bill_after, :to => :calculation_engine
  delegate :average_monthly_cost_after, :to => :calculation_engine
  
  
  #
  # Savings
  #
  
  delegate :first_year_savings, :to => :calculation_engine
  delegate :lifetime_savings, :to => :calculation_engine
  
  delegate :average_monthly_savings, :to => :calculation_engine
  
  
  #
  # Loan
  #
  
  delegate :monthly_loan_payment, :to => :calculation_engine
  
  
  #
  # Incentives
  #
  
  delegate :increase_in_home_value, :to => :calculation_engine
  delegate :total_value_of_federal_incentives, :to => :calculation_engine
  delegate :total_value_of_state_and_local_incentives, :to => :calculation_engine
  
  
  #
  # Miscellaneous readers
  #
  
  def received
    created_at
  end
  
  def module_type
    photovoltaic_module.manufacturer_and_description
  end
  
  def inverter_type
    photovoltaic_inverter.manufacturer_and_description
  end
  
  def module_stc_rating
    photovoltaic_module.blank? ? 0.0 : photovoltaic_module.stc_rating
  end
  
  def module_ptc_rating
    photovoltaic_module.blank? ? 0.0 : photovoltaic_module.ptc_rating
  end
  
  def module_count
    number_of_modules.blank? ? 0.0 : number_of_modules
  end
  
  def inverter_weighted_efficiency
    photovoltaic_inverter.blank? ? 93.percent : photovoltaic_inverter.weighted_efficiency
  end
  
  def installer_proximity_to_customer
    partner.distance_from(customer)
  end
  
  def year_founded
    partner.in_business_since
  end
  
  delegate :postal_code, :to => :profile
  delegate :city, :to => :profile
  delegate :customer, :to => :profile
  
  delegate :total_kw_installed, :to => :partner
  
  
  #
  # Miscellaneous writers
  #
  
  attr_accessor :photovoltaic_module_manufacturer
  attr_accessor :photovoltaic_inverter_manufacturer
  
  def set_manufacturers
    self.photovoltaic_module_manufacturer = photovoltaic_module.manufacturer unless photovoltaic_module.blank?
		self.photovoltaic_inverter_manufacturer = photovoltaic_inverter.manufacturer unless photovoltaic_inverter.blank?
  end
  
  
private
  
  #
  # Caching
  #
  
  attr_accessor :cached_calculation_engine
  
  
  #
  # Initialization
  #
  
  def calculation_engine
    self.cached_calculation_engine = QuoteCalculationEngine.new(self) if cached_calculation_engine.nil?
    cached_calculation_engine
  end
  
  
  #
  # Miscellaneous writers
  #
  
  [ :system_price, :installation_estimate ].each do |m|
    module_eval <<-"end_eval", __FILE__, (__LINE__ + 1)
      def raw_#{m.to_s}=(s)
        as_f = convert_string_to_positive_float(s)
        self.#{m.to_s} = as_f > 0.0 ? as_f : nil
      end
    end_eval
  end
end
