class QuoteCalculationEngine < CalculationEngine
  #
  # Initialization
  #
  
  def initialize(quote)
    @quote = quote
    super(quote.profile)
  end
  
  
  #
  # Sizing
  #
  
  def nameplate_rating
    (@quote.module_stc_rating * @quote.module_count) / 1000.0
  end

  def cec_rating
    ((@quote.module_ptc_rating * @quote.module_count) * @quote.inverter_weighted_efficiency) / 1000.0
  end
  alias :cec_rating_without_derate :cec_rating
  
  
  #
  # Output
  #
  
  def annual_output(n = 1)
    starting_output * system_efficiency_at_year(n)
  end
  
  
  #
  # Usage
  #
  
  def annual_usage_after(n = 1)
    @profile.annual_usage - annual_output(n)
  end
  
  
  #
  # Cost
  #
  
  def system_cost
    @quote.system_price.blank? ? 0.0 : @quote.system_price
  end
  
  def installation_cost
    @quote.installation_estimate.blank? ? 0.0 : @quote.installation_estimate
  end
  
  def cash_outlay
    @quote.will_accept_rebate_assignment? ? net_system_cost : (project_cost + sales_tax - total_value_of_federal_incentives)
  end
  

private
  
  #
  # Output
  #
  
  def starting_output
    #((@quote.module_ptc_rating * @quote.module_count) * (@profile.annual_solar_rating / @@average_national_annual_solar_rating) * (@quote.inverter_weighted_efficiency / 93.percent) * 1.89)
    ((@quote.module_ptc_rating * @quote.module_count) * (@profile.annual_solar_rating / @@average_national_annual_solar_rating) * @quote.inverter_weighted_efficiency * 2.23)
  end
end