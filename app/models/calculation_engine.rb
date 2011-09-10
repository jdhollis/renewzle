class CalculationEngine
  #
  # Initialization
  #
  
  def initialize(profile)
    @profile = profile
    @utility = profile.utility
  end
  
  
  #
  # Sizing
  #
  
  def nameplate_rating(output = annual_output)
    (output / 1.89 * (@@average_national_annual_solar_rating / @profile.annual_solar_rating) / 1000.0) / system_efficiency_given(@profile.system_performance_derate)
  end
  
  def cec_rating(output = annual_output)
    nameplate_rating(output) * @@ac_dc_ratio
  end
  
  def cec_rating_without_derate
    cec_rating(annual_output_without_derate)
  end
  
  def cost_adjusted_size
    cec_rating + 1 / ((cec_rating + 2) ** 2)
  end
  
  def monthly_cost_optimal_offset
    minimum_cost = monthly_electric_cost_by_offset.values.min
    maximum_offset = 0.0
    monthly_electric_cost_by_offset.each do |offset, cost|
      maximum_offset = offset if cost == minimum_cost && offset > maximum_offset
    end
    maximum_offset
  end
  
  
  #
  # System cost
  #
  
  def system_cost
    cost_adjusted_size.kw * @@system_cost_per_ac_watt
  end
  
  def installation_cost
    cost_adjusted_size.kw * @@installation_cost_per_ac_watt
  end
  
  def project_cost
    @profile.usage_offset > 0 ? (system_cost + installation_cost) : 0.0
  end
  alias :total_price :project_cost
  
  def sales_tax
    @profile.usage_offset > 0 ? (system_cost - total_value_of_state_and_local_incentives) * @profile.sales_tax_rate : 0.0
  end
  
  def net_system_cost
    project_cost + sales_tax - total_value_of_federal_incentives - total_value_of_state_and_local_incentives
  end
  
  def average_dollar_cost_per_nameplate_watt
    total_price / nameplate_rating.kw
  end
  
  def average_dollar_cost_per_cec_watt
    total_price / cec_rating.kw
  end
  
  def average_dollar_system_cost_per_nameplate_watt
    system_cost / nameplate_rating.kw
  end
  
  def average_dollar_installation_cost_per_nameplate_watt
    installation_cost / nameplate_rating.kw
  end
  
  def average_dollar_system_cost_per_cec_watt
    system_cost / cec_rating.kw
  end
  
  def average_dollar_installation_cost_per_cec_watt
    installation_cost / cec_rating.kw
  end
  
  
  #
  # Annual usage, output, and bill calculations
  #
  
  def annual_usage
    if cached_annual_usage.nil?
      annual_usage = 0.0
      adjusted_average_monthly_bill = remove_utility_tax_from(@profile.average_monthly_bill)
      [ "Summer", "Winter" ].each do |season|
        usage = 0.0
        cumulative_amount = tariff.fixed_amount
        
        tiers = tariff.send("#{season.downcase}_variable_tiers")
        
        tiered_fixed_tiers = tariff.tiered_fixed_tiers
        fixed_tier_amount = 0.0
        tiered_fixed_tiers.each do |tiered_fixed_tier|
          unless tiered_fixed_tier.max_usage.blank?
            max_variable_amount = tiered_fixed_tier.max_usage * tiers.first.rate
            max_fixed_tier_amount = max_variable_amount + tiered_fixed_tier.rate
          else
            fixed_tier_amount = tiered_fixed_tier.rate
            break
          end
          
          if adjusted_average_monthly_bill > max_fixed_tier_amount
            fixed_tier_amount = tiered_fixed_tier.rate
          else
            break
          end
        end
        
        cumulative_amount = cumulative_amount + fixed_tier_amount
        
        previous_tier_max_usage = 0.0
        tiers.each do |tier|
          if tier.max_tier_amount > 0 && adjusted_average_monthly_bill > (cumulative_amount + tier.max_tier_amount)
            cumulative_amount = cumulative_amount + tier.max_tier_amount
            previous_tier_max_usage = tier.max_usage
          else
            usage = ((adjusted_average_monthly_bill - cumulative_amount) / tier.rate) + previous_tier_max_usage
            break
          end
        end
        
        case season
        when "Summer"
          usage = usage * (@utility.summer_ending_month - @utility.summer_starting_month + 1)
        when "Winter"
          usage = usage * (11 - (@utility.summer_ending_month - @utility.summer_starting_month))
        end
      
        annual_usage = annual_usage + usage
      end
    
      self.cached_annual_usage = annual_usage
    end
    
    cached_annual_usage
  end
  
  def annual_output(n = 1)
    annual_usage * @profile.usage_offset * system_efficiency_at_year(n)
  end
  
  def annual_usage_after(n = 1)
    annual_usage - annual_output(n)
  end
  
  def annual_bill
    if cached_annual_bill.nil?
      self.cached_annual_bill = bill_without_solar_by_month.values.inject(0.0) { |total_bill, bill| total_bill + bill }
    end
    
    cached_annual_bill
  end
  
  def annual_bill_after(n = 1)
    bill_with_solar_by_month(n).values.inject(0.0) { |total_bill, bill| total_bill + bill }
  end
  
  
  #
  # Monthly usage, output, and bill calculations
  #
  
  def average_monthly_usage_before
    annual_usage / 12.0
  end
  
  def average_monthly_cost_before
    annual_bill / 12.0
  end
  
  def average_monthly_bill_after
    annual_bill_after / 12.0
  end
  
  def average_monthly_cost_after
    average_monthly_bill_after + monthly_loan_payment - monthly_tax_effect
  end
  
  def usage_without_solar_by_month
    if cached_usage_without_solar_by_month.nil?
      usage_by_month = Hash.new
      12.downto(1) do |n|
        month = Date.today.months_ago(n)
        usage_by_month[month] = annual_usage * @utility.load_for(month)
      end
      self.cached_usage_without_solar_by_month = usage_by_month
    end
    
    cached_usage_without_solar_by_month
  end
  
  def usage_with_solar_by_month(n = 1)
    returning(Hash.new) do |usage_by_month|
      monthly_output = output_by_month(n)
      monthly_output.each do |month, output|
        usage_by_month[month] = usage_without_solar_by_month[month] - output
      end
    end
  end
  
  def bill_without_solar_by_month
    if cached_bill_without_solar_by_month.nil?
      bill_by_month = Hash.new
      usage_without_solar_by_month.each do |month, usage|
        rounded_usage = usage
        amount = tariff.fixed_amount + tariff.tiered_fixed_amount_for(rounded_usage)
        tiers = tariff.variable_tiers_for(@utility.season_for(month))
        tiers.each do |tier|
          if tier.max_usage.blank? || (rounded_usage <= tier.max_usage && rounded_usage >= tier.min_usage)
            amount = amount + ((rounded_usage - tier.min_usage) * tier.rate)
            break
          elsif rounded_usage > tier.max_usage
            amount = amount + (tier.max_tier_usage * tier.rate)
          end
        end
        bill_by_month[month] = add_utility_tax_to([ amount, tariff.minimum_amount ].max)
      end
      
      self.cached_bill_without_solar_by_month = bill_by_month
    end
    
    cached_bill_without_solar_by_month
  end
  
  def bill_with_solar_by_month(n = 1)
    returning(Hash.new) do |bill_by_month|
      usage_by_month = usage_with_solar_by_month(n)
      usage_by_month.each do |month, usage|
        absolute_value_of_usage = usage.abs.round
        amount = tariff.fixed_amount + tariff.tiered_fixed_amount_for(absolute_value_of_usage)
        tiers = tariff.variable_tiers_for(@utility.season_for(month))
        tiers.each do |tier|
          if tier.max_usage.blank? || (absolute_value_of_usage <= tier.max_usage && absolute_value_of_usage >= tier.min_usage)
            amount = amount + ((absolute_value_of_usage - tier.min_usage) * tier.rate)
            break
          elsif absolute_value_of_usage > tier.max_usage
            amount = amount + (tier.max_tier_usage * tier.rate)
          end
        end
        
        if usage < 0
          amount = -amount
        else
          amount = add_utility_tax_to([ amount, tariff.minimum_amount ].max)
        end
        
        bill_by_month[month] = amount
      end
    end
  end
  
  
  #
  # Savings
  #
  
  def first_year_savings
    annual_savings_for_year(1)
  end
  
  def lifetime_savings
    savings = 0.0
    1.upto(@profile.system_life) do |n|
      savings = savings + annual_savings_for_year(n)
    end
    savings
  end
  
  def average_monthly_savings
    average_monthly_cost_before - average_monthly_cost_after
  end
  
  
  #
  # Loan
  #
  
  def loan_principal
    @profile.usage_offset > 0 ? net_system_cost : 0.0
  end
  
  def monthly_loan_payment
    unless @profile.customer_has_not_provided_enough_loan_information?
      if @profile.annual_interest_rate > 0 && @profile.loan_term > 0
        (@profile.monthly_interest_rate * loan_principal) / (1 - ((1 + @profile.monthly_interest_rate) ** (- @profile.number_of_monthly_loan_payments)))
      else
        0.0
      end
    else
      0.0
    end
  end
  
  
  #
  # Taxes
  #
  
  def monthly_federal_tax_effect
    interest_portion_of_monthly_loan_payment * @profile.marginal_federal_tax_rate
  end
  
  def monthly_state_tax_effect
    interest_portion_of_monthly_loan_payment * @profile.marginal_state_tax_rate
  end
  
  def monthly_tax_effect
    monthly_federal_tax_effect + monthly_state_tax_effect
  end
  
  
  #
  # Incentives
  #
  
  def total_value_of_federal_incentives
    total_value_of(:federal_incentives)
  end
  
  def total_value_of_state_and_local_incentives
    total_value_of(:state_and_local_incentives)
  end
  
  def increase_in_home_value
    [ (change_in_annual_bill * @@home_value_increase_rate), 0.0 ].max
  end
  
  
  #
  # Charting
  #
  
  def monthly_electric_cost_by_offset
    if cached_monthly_electric_cost_by_offset.nil?
      cost_by_offset = {}
      0.upto(100) do |offset|
        next if offset > 0 && offset % 5 > 0
        @profile.current_offset = offset.percent
        cost_by_offset[offset] = average_monthly_cost_after
      end
      @profile.current_offset = nil
      self.cached_monthly_electric_cost_by_offset = cost_by_offset
    end
    
    cached_monthly_electric_cost_by_offset
  end

  def annual_cost_before_and_after
    returning(Hash.new) do |annual_cost|
      1.upto(@profile.system_life) do |year|
        annual_cost[year] = {}
        annual_cost[year][:before] = annual_cost_before_for_year(year)
        annual_cost[year][:after] = annual_cost_after_for_year(year)
      end
    end
  end

  def cumulative_annual_savings
    returning(Hash.new) do |annual_savings|
      savings_to_date = 0.0
      1.upto(@profile.system_life) do |year|
        savings_to_date = savings_to_date + annual_savings_for_year(year)
        annual_savings[year] = savings_to_date
      end
    end
  end
  
  
  #
  # Emissions
  #
  
  def average_monthly_co2_emissions_before
    annual_co2_emissions_before / 12.0
  end

  def average_monthly_co2_emissions_after
    annual_co2_emissions_after / 12.0
  end
  
  [ :co2, :so2, :nox, :mercury ].each do |which|
    module_eval <<-"end_eval", __FILE__, (__LINE__ + 1)
      def annual_#{which}_emissions_before
        emissions_given(:#{which}, annual_usage)
      end

      def annual_#{which}_emissions_after
        emissions_given(:#{which}, annual_usage_after)
      end
    end_eval
  end
  
  [ :co2, :so2, :nox ].each do |which|
    module_eval <<-"end_eval", __FILE__, (__LINE__ + 1)
      def self.#{which}_emissions_given(usage, rate = average_lbs_#{which}_per_kwh)
        emissions_given(usage, rate)
      end
    end_eval
  end
  
  def self.mercury_emissions_given(usage, rate = average_lbs_mercury_per_kwh * 16.0)
    emissions_given(usage, rate)
  end
  
  
  #
  # Comparables
  #
  
  def monthly_trees_planted_before
    0
  end
  
  def monthly_trees_planted_after
    monthly_co2_emissions_change / @@average_lifetime_lbs_co2_absorbed_per_tree
  end
  
  def monthly_cars_removed_before
    0
  end
  
  def monthly_cars_removed_after
    monthly_co2_emissions_change / @@average_monthly_lbs_co2_generated_per_car
  end
  
  
  #
  # Miscellaneous class methods
  #
  
  def self.electricity_rate_at_year(n, rate)
    n == 1 ? rate : rate * ((1 + @@yearly_percentage_increase_in_electricity_rates) ** (n - 1))
  end
  
  cattr_reader :average_system_life
  
  cattr_reader :average_national_annual_solar_rating
  
  def self.average_national_monthly_insolation
    average_national_annual_solar_rating / 12.0
  end
  
  cattr_reader :system_cost_per_ac_watt
  cattr_reader :installation_cost_per_ac_watt
  
  
private
  
  #
  # Caching
  #
  
  attr_accessor :cached_annual_usage
  attr_accessor :cached_annual_bill
  attr_accessor :cached_usage_without_solar_by_month
  attr_accessor :cached_bill_without_solar_by_month
  
  attr_accessor :cached_loan_balance_for_year
  attr_accessor :cached_principal_payment_for_year
  attr_accessor :cached_interest_payment_for_year
  
  attr_accessor :cached_monthly_electric_cost_by_offset
  
  
  #
  # Finders
  #
  
  def tariff
    @utility.tariff_for(@profile.region)
  end
  
  
  #
  # Class constants
  #
  
  @@yearly_percentage_increase_in_electricity_rates = 0.05
  
  @@average_lbs_co2_per_kwh = 1.107
  @@average_lbs_so2_per_kwh = 0.0
  @@average_lbs_nox_per_kwh = 0.0
  @@average_lbs_mercury_per_kwh = 0.0
  
  @@average_lifetime_lbs_co2_absorbed_per_tree = 671
  @@average_monthly_lbs_co2_generated_per_car = (0.9142 * 12000) / 12 # 0.9142 pounds of CO2 per mile driven * 12,000 miles per year
  
  @@ac_dc_ratio = 0.85
  @@average_national_annual_solar_rating = 5344.0
  
  @@yearly_percent_decrease_in_system_efficiency = 0.005
  
  @@average_system_life = 25
  
  @@system_cost_per_ac_watt = 7.0
  @@installation_cost_per_ac_watt = 2.2
  
  @@home_value_increase_rate = 20.0  # $20 increase for every $1 decrease in operating cost
  
  # at about year 15, the inverters will have to replaced at a cost of about $1.20 / nameplate Watt
  @@average_inverter_life = 15
  @@average_inverter_replacement_cost_per_dc_watt = 1.5
  
  
  #
  # Emissions
  #
  
  def monthly_co2_emissions_change
    average_monthly_co2_emissions_before - average_monthly_co2_emissions_after
  end
  
  def emissions_given(which, usage)
    @utility.send("#{which}_emissions_given", usage)
  end
  
  def self.emissions_given(usage, rate)
    usage * rate
  end
  
  
  #
  # Output
  #
  
  def annual_output_without_derate
    annual_usage * @profile.usage_offset
  end
  
  def system_efficiency_given(derate)
    100.percent - derate
  end

  def system_efficiency_at_year(n)
    n == 1 ? 100.percent : 100.percent - (@@yearly_percent_decrease_in_system_efficiency ** (n - 1))
  end
  
  def output_by_month(n = 1)
    returning(Hash.new) do |monthly_output|
      total_yearly_insolation = @profile.total_yearly_insolation
      12.downto(1) do |m|
        month = Date.today.months_ago(m)
        monthly_output[month] = annual_output(n) * (@profile.insolation_for(month) / total_yearly_insolation)
      end
    end
  end
  
  
  #
  # Cost / savings
  #
  
  def annual_bill_after_for_year(n)
    annual_bill_after(n) * ((1 + @@yearly_percentage_increase_in_electricity_rates) ** (n - 1))
  end
  
  def inverter_replacement_cost_at_year(n)
    n == @@average_inverter_life ? (nameplate_rating.kw * @@average_inverter_replacement_cost_per_dc_watt) : 0.0
  end
  
  def annual_cost_after_for_year(n)
    annual_bill_after_for_year(n) + loan_payment_for_year(n) - tax_effect_for_year(n) + inverter_replacement_cost_at_year(n)
  end
  
  def annual_cost_before_for_year(n)
    annual_bill * ((1 + @@yearly_percentage_increase_in_electricity_rates) ** (n - 1))
  end
  
  def annual_savings_for_year(n)
    annual_cost_before_for_year(n) - annual_cost_after_for_year(n)
  end
  
  
  #
  # Bill
  #
  
  ######
  # The 6.653% represents electricity taxes that are rolled into a monthly electric bill.
  # This 6.653% will need to be factored into a state-level constant of some sort.
  #
  
  def add_utility_tax_to(bill)
    @profile.state == "CA" ? (bill * (1 + 6.653.percent)) : bill
  end
  
  def remove_utility_tax_from(bill)
    @profile.state == "CA" ? (bill / (1 + 6.653.percent)) : bill
  end
  
  #
  ######
  
  def change_in_annual_bill
    annual_bill - annual_bill_after
  end
  
  
  #
  # Incentives
  #
  
  def total_value_of(incentive_kind)
    @profile.send(incentive_kind).inject(0.0) { |total, incentive| total + incentive.value_for(@profile) }
  end
  
  
  #
  # Loan
  #
  
  def interest_portion_of_monthly_loan_payment
    loan_principal * @profile.monthly_interest_rate
  end
  
  def loan_payment_for_year(n)
    loan_balance_for_year(n - 1) > 0 ? [ monthly_loan_payment * 12.0, loan_balance_for_year(n - 1) ].min : 0.0
  end
  
  def interest_payment_for_year(n)
    self.cached_interest_payment_for_year = {} if cached_interest_payment_for_year.nil?
    
    unless cached_interest_payment_for_year.has_key?(n)
      if loan_balance_for_year(n - 1) > 0
        cached_interest_payment_for_year[n] = loan_balance_for_year(n - 1) * @profile.annual_interest_rate
      else
        cached_interest_payment_for_year[n] = 0.0
      end
    end
    
    cached_interest_payment_for_year[n]
  end
  
  def principal_payment_for_year(n)
    self.cached_principal_payment_for_year = {} if cached_principal_payment_for_year.nil?
    
    unless cached_principal_payment_for_year.has_key?(n)
      cached_principal_payment_for_year[n] = loan_payment_for_year(n) - interest_payment_for_year(n)
    end
    
    cached_principal_payment_for_year[n]
  end
  
  def loan_balance_for_year(n)
    self.cached_loan_balance_for_year = {} if cached_loan_balance_for_year.nil?
    
    unless cached_loan_balance_for_year.has_key?(n)
      if n == 0
        cached_loan_balance_for_year[n] = loan_principal
      elsif @profile.year_is_within_loan_term?(n)
        cached_loan_balance_for_year[n] = loan_balance_for_year(n - 1) - principal_payment_for_year(n)
      else
        cached_loan_balance_for_year[n] = 0.0
      end
    end
    
    cached_loan_balance_for_year[n]
  end
  
  
  #
  # Taxes
  #
  
  def federal_tax_effect_for_year(n)
    interest_payment_for_year(n) * @profile.marginal_federal_tax_rate
  end
  
  def state_tax_effect_for_year(n)
    interest_payment_for_year(n) * @profile.marginal_state_tax_rate
    
  end
  
  def tax_effect_for_year(n)
    federal_tax_effect_for_year(n) + state_tax_effect_for_year(n)
  end
end