class PercentageOfProjectCostIncentive < Incentive
  def value_for(profile_or_quote)
    if applicable_to(profile_or_quote)
      value = profile_or_quote.project_cost * rate
      if maximum_amount.blank?
        value
      else
        [ value, maximum_amount ].min
      end
    else
      0.0
    end
  end
end