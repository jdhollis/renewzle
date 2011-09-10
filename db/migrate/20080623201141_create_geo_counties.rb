class CreateGeoCounties < ActiveRecord::Migration
  def self.up
    create_table :geo_counties do |t|
      t.column :postal_code, :string
      t.column :city_name, :string
      t.column :county_name, :string
      t.column :state_code, :string
    end
  end

  def self.down
    drop_table :geo_counties
  end
end
