class Utility < ActiveRecord::Base
  has_many :incentives, :dependent => :destroy  
  has_many :tariffs, :order => 'region ASC', :dependent => :destroy do
    def for_region(region)
      find_all_by_region(region)
    end
  end

  def source_mix
    returning Hash.new do |mix|
      methods_and_descriptions = { 
        :percent_coal => "Coal", 
        :percent_oil => "Oil", 
        :percent_gas => "Natural gas", 
        :percent_nuclear => "Nuclear", 
        :percent_hydro => "Hydroelectric", 
        :percent_biomass => "Biomass", 
        :percent_wind => "Wind", 
        :percent_solar => "Solar",
        :percent_geothermal => "Geothermal",
        :percent_other => "Other fossil",
        :percent_unknown => "Unknown / Purchased"
      }
          
      methods_and_descriptions.each do |method, description|
        value = send(method)
        next unless !value.blank? && value > 0
        mix[description] = value
      end
    end
  end
    
  [ :co2, :so2, :nox, :mercury ].each do |which|
    module_eval <<-"end_eval", __FILE__, (__LINE__ + 1)
      def #{which}_emissions_given(usage)
        emissions_given(:#{which}, usage)
      end
    end_eval
  end

  def electricity_rate
    rate.blank? ? 0.08547 : rate
  end

  def tariff_for(region)
    has_tariffs_for(region) ? tariffs_for(region).first : nil
  end
  
  def season_for(date)
    month = date.strftime('%m').to_i
    starting_month = summer_starting_month.blank? ? 5 : summer_starting_month
    ending_month = summer_ending_month.blank? ? 9 : summer_ending_month
    (starting_month..ending_month).include?(month) ? 'Summer' : 'Winter'
  end
  
  def load_for(date)
    load = self.send(date.strftime('%b').downcase.to_sym)
    load.blank? ? (1 / 12.0) : load
  end

  def has_region_map?
    !region_map.blank?
  end

private

  attr_accessor :cached_tariffs_for, :cached_tariff_count
  
  def tariffs_for(region)
    self.cached_tariffs_for = {} if cached_tariffs_for.nil?
    self.cached_tariff_count = tariffs.size if cached_tariff_count.nil?
    
    if cached_tariff_count > 1
      cached_tariffs_for[region] = tariffs.for_region(region) unless cached_tariffs_for.has_key?(region)
    else
      cached_tariffs_for[region] = [ tariffs.first ] unless cached_tariffs_for.has_key?(region)
    end
    
    cached_tariffs_for[region]
  end

  def has_tariffs_for(region)
    !tariffs_for(region).blank?
  end
  
  def emissions_given(which, usage)
    if self.send("#{which}_rate").blank?
      CalculationEngine.send("#{which}_emissions_given", usage)
    else
      CalculationEngine.send("#{which}_emissions_given", usage, self.send("#{which}_rate"))
    end
  end
end
