class GeoCounty < ActiveRecord::Base
  def self.states
    self.find_by_sql ["SELECT state_code FROM geo_counties GROUP BY state_code"]
  end
  
  def self.counties
    self.find_by_sql ["SELECT id, county_name, state_code WHERE"]
  end
end
