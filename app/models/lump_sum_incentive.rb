class LumpSumIncentive < Incentive
  def value_for(profile_or_quote)
    applicable_to(profile_or_quote) ? rate : 0.0
  end
end