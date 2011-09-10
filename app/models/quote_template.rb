class QuoteTemplate < ActiveRecord::Base
  include Renewzle::Conversions
  include ActionView::Helpers::NumberHelper
  
  acts_as_soft_deletable
  
	belongs_to :partner
  belongs_to :photovoltaic_module
  belongs_to :photovoltaic_inverter
  
  belongs_to :company_backgrounder
  
  attr_accessible :partner_id, :photovoltaic_module_id, :number_of_modules, :photovoltaic_inverter_id, :description, :number_of_inverters, :system_price, :installation_estimate, :installation_available, :will_accept_rebate_assignment, :photovoltaic_inverter_manufacturer, :partner, :photovoltaic_module_manufacturer, :raw_system_price, :raw_installation_estimate, :company_backgrounder_id


  #
  # Validations
  #

  validates_presence_of :partner_id
  validates_presence_of :photovoltaic_module_id
  validates_presence_of :number_of_modules
  validates_presence_of :photovoltaic_inverter_id
  validates_presence_of :description
  validates_length_of :description, :maximum => 255, :allow_nil => true
  validates_presence_of :number_of_inverters
  validates_presence_of :system_price
  validates_presence_of :installation_estimate, :if => Proc.new { |record| record.installation_available? }
  
  
  #
  # Callbacks
  #
  
  before_validation do |record|
    record.description = "#{record.number_with_delimiter(record.number_with_precision(record.nameplate_rating, 1))} DC kW system" if record.description.blank?
  end
  
  
  #
  # Apply to
  #
  
  def apply_to(quote)
    [ :photovoltaic_module, :number_of_modules, :photovoltaic_inverter, :number_of_inverters, :system_price, :installation_available, :installation_estimate, :will_accept_rebate_assignment, :company_backgrounder ].each do |sym|
      quote.send("#{sym}=", self.send(sym))
    end
    
    quote.set_manufacturers
  end
  

  #
  # Sizing
  #

  delegate :nameplate_rating, :to => :calculation_engine
  delegate :cec_rating, :to => :calculation_engine


  #
  # System cost
  #

  delegate :system_cost, :to => :calculation_engine
  delegate :installation_cost, :to => :calculation_engine
  delegate :project_cost, :to => :calculation_engine


  #
  # Annual output
  #

  delegate :annual_output, :to => :calculation_engine


  #
  # Miscellaneous readers
  #

  def module_type
    photovoltaic_module.model_and_description
  end

  def inverter_type
    photovoltaic_inverter.model_and_description
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
    self.cached_calculation_engine = QuoteTemplateCalculationEngine.new(self) if cached_calculation_engine.nil?
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
