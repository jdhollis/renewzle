class PerKwhIncentive < Incentive
  def value_for(profile_or_quote)
    if applicable_to(profile_or_quote) && !rate.blank?
      value = profile_or_quote.annual_output * rate
    
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