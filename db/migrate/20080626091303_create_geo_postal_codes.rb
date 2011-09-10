class CreateGeoPostalCodes < ActiveRecord::Migration
  def self.up
    create_table :geo_states, :force => true do |t|
      t.string :state_code
    end
    
    create_table :geo_regions, :force => true do |t|
      t.integer :geo_state_id
      t.string :region_name
    end
    add_index :geo_regions, :geo_state_id
    
    create_table :geo_cities, :force => true do |t|
      t.integer :geo_region_id
      t.string :city_name
      t.string :postal_code
    end
    add_index :geo_cities, :geo_region_id
    
    create_table :companies_geo_regions, :force => true, :id => false, :primary_key => [ :company_id, :geo_region_id ] do |t|
      t.integer :company_id
      t.integer :geo_region_id
    end
    
    add_column :users, :can_manage_counties, :boolean, :default => true
  end

  def self.down
    drop_table :companies_geo_regions
    drop_table :geo_regions
    drop_table :geo_cities
    drop_table :geo_states
    remove_column :users, :can_manage_counties
  end
end
