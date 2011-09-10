class QuoteTemplateCalculationEngine < CalculationEngine
  #
  # Initialization
  #
  
  def initialize(quote_template)
    @quote_template = quote_template
  end
  
  
  #
  # Sizing
  #
  
  def nameplate_rating
    (@quote_template.module_stc_rating * @quote_template.module_count) / 1000.0
  end

  def cec_rating
    ((@quote_template.module_ptc_rating * @quote_template.module_count) * @quote_template.inverter_weighted_efficiency) / 1000.0
  end
  
  
  #
  # Output
  #
  
  def annual_output
    (@quote_template.module_ptc_rating * @quote_template.module_count) * (@quote_template.inverter_weighted_efficiency * 2.23)
  end
  
  
  #
  # Cost
  #
  
  def system_cost
    @quote_template.system_price.blank? ? 0.0 : @quote_template.system_price
  end
  
  def installation_cost
    @quote_template.installation_estimate.blank? ? 0.0 : @quote_template.installation_estimate
  end
end