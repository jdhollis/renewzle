class Tariff < ActiveRecord::Base
  belongs_to :utility
  
  has_one :minimum_tier
  has_many :fixed_tiers
  has_many :variable_tiers, :order => 'min_usage ASC' do
    def for_season(season)
      find_all_by_season(season)
    end
  end
  has_many :tiered_fixed_tiers, :order => 'min_usage ASC'
  
  def minimum_amount
    minimum_tier.blank? ? 0.0 : minimum_tier.rate
  end
  
  def fixed_amount
    fixed_tiers.inject(0.0) { |amount, fixed_tier| amount + fixed_tier.rate }
  end
  
  def tiered_fixed_amount_for(usage)
    amount = 0.0
    
    tiered_fixed_tiers.each do |tiered_fixed_tier|
      if !tiered_fixed_tier.max_usage.blank? && usage > tiered_fixed_tier.max_usage
        next
      elsif usage >= tiered_fixed_tier.min_usage
        amount = tiered_fixed_tier.rate
        break
      end
    end
    
    amount
  end
  
  def summer_variable_tiers
    variable_tiers_for('Summer')
  end
  
  def winter_variable_tiers
    variable_tiers_for('Winter')
  end
  
  def variable_tiers_for(season)
    self.cached_variable_tiers_for = {} if cached_variable_tiers_for.nil?
    
    unless cached_variable_tiers_for.has_key?(nil)
      cached_variable_tiers_for[nil] = variable_tiers.for_season(nil)
    end
    
    unless cached_variable_tiers_for.has_key?(season)
      cached_variable_tiers_for[season] = variable_tiers.for_season(season)
    end
    
    cached_variable_tiers_for[nil] + cached_variable_tiers_for[season]
  end
  
private
  
  #
  # Caching
  #
  
  attr_accessor :cached_variable_tiers_for
end
