class PerCecWattIncentive < PerWattIncentive
  def watts_for(profile_or_quote)
    cec_rating = derate? ? profile_or_quote.cec_rating : profile_or_quote.cec_rating_without_derate
    cec_rating.kw
  end
end
