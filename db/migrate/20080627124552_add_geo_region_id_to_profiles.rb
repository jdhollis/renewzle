class AddGeoRegionIdToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :geo_region_id, :integer
    add_index :profiles, :geo_region_id
  end

  def self.down
    remove_column :profiles, :geo_region_id
  end
end
