class GeoRegion < ActiveRecord::Base
  has_many :geo_cities, :dependent => :destroy
  belongs_to :geo_state
  has_and_belongs_to_many :companies, :uniq => true
  
  def self.store_with_state(state_code, county_name)
    geo_state = GeoState.find_or_create_by_state_code(state_code)
    if geo_state.new_record?
      geo_state.save!
    end

    geo_region = geo_state.geo_regions.find_or_create_by_region_name(county_name)
    if geo_region.new_record?
      geo_region.save!
    end
    return geo_region
  end
end
