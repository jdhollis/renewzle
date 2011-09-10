class GeoState < ActiveRecord::Base
  has_many :geo_regions, :dependent => :destroy
end
