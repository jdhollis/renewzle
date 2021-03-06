class PerWattIncentive < Incentive
  def derate?
    derate
  end
  
  def value_for(profile_or_quote)
    if applicable_to(profile_or_quote)
      value = watts_for(profile_or_quote) * rate
    
      if maximum_amount.blank? && maximum_percentage.blank?
        value
      else
        unless maximum_amount.blank?
          maximum = maximum_amount
        else
          maximum = maximum_percentage * profile_or_quote.total_price
        end
      
        [ value, maximum ].min
      end
    else
      0.0
    end
  end
end