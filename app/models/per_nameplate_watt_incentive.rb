class PerNameplateWattIncentive < PerWattIncentive
  def watts_for(profile_or_quote)
    profile_or_quote.nameplate_rating.kw
  end
end