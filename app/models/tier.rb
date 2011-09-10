class Tier < ActiveRecord::Base
  belongs_to :tariff
  
  def max_tier_amount
    rate * max_tier_usage
  end
  
  def max_tier_usage
    unless max_usage.blank?
      (max_usage - min_usage)
    else
      0.0
    end
  end
end