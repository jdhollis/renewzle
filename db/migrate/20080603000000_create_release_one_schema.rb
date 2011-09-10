class CreateReleaseOneSchema < ActiveRecord::Migration
  def self.up
    create_table :cec_companies do |t|
      t.string :name, :email, :url
      t.string :street_address, :city, :state, :postal_code, :country
      t.string :phone_number, :fax_number
      t.float :lat, :lng, :distance
      t.boolean :geocodable, :installs
      t.boolean :claimed, :default => false
      t.timestamps
    end

    add_index :cec_companies, :name

    create_table :companies do |t|
      t.string :name, :email, :url
      t.string :street_address, :city, :state, :postal_code, :country
      t.string :phone_number, :fax_number
      t.float :lat, :lng, :distance
      t.boolean :geocodable, :installs, :claimed
      t.string :cec_company_hash
      t.string :total_kw_installed, :contractors_license_number, :in_business_since
      t.timestamps
    end

    create_table :discounts do |t|
      t.integer :company_id
      t.string :type
      t.float :price, :percentage
      t.timestamps
    end
    
    create_table :incentives do |t|
      t.string :type, :city, :state, :source, :description, :notes
      t.integer :utility_id
      t.boolean :derate, :default => false
      t.float :rate, :minimum_system_size, :maximum_system_size, :maximum_amount, :maximum_percentage
      t.timestamps
    end
    
    create_table :income_tax_brackets do |t|
      t.string :type, :state, :filing_status
      t.float :income_min, :income_max, :rate
      t.timestamps
    end
    
    create_table :leads do |t|
  		t.integer :partner_id, :quote_id
  		t.string :confirmation_number, :authorization, :ip_address, :discount
  		t.boolean :purchased, :default => false
  		t.boolean :closed, :default => false
      t.timestamps
    end
    
    create_table :login_tokens do |t|
      t.integer :user_id
      t.string :value
      t.timestamps
    end
    
    create_table :photovoltaic_inverters do |t|
      t.string :manufacturer, :model_number
      t.text :description
      t.integer :power_rating
      t.float :weighted_efficiency
      t.timestamps
    end

    create_table :photovoltaic_modules do |t|
      t.string :manufacturer, :model_number
      t.text :description
      t.float :stc_rating, :ptc_rating
      t.timestamps
    end
    
    create_table :profiles do |t|
      t.integer :customer_id, :utility_id, :solar_rating_id, :federal_income_tax_bracket_id, :state_income_tax_bracket_id, :lead_id
      t.string :street_address, :city, :state, :postal_code
      t.float :average_monthly_bill
      t.float :annual_interest_rate, :default => 0.06
      t.float :percentage_to_offset, :default => 1.0
      t.integer :loan_term, :default => 25
      t.boolean :rfq, :default => false
      t.boolean :second_chance, :default => false
      t.string :filing_status, :default => 'Married'
      t.float :income, :default => 100000.0
      t.string :region
      t.float :system_performance_derate, :default => 0.0
      t.timestamps
    end
    
    create_table :quotes do |t|
      t.integer :profile_id, :partner_id, :photovoltaic_module_id, :number_of_modules, :photovoltaic_inverter_id, :number_of_inverters
      t.float :system_price, :installation_estimate
      t.boolean :installation_available, :default => true
      t.boolean :will_accept_rebate_assignment, :default => false
      t.timestamps
    end
    
    create_table :sales_taxes do |t|
      t.string :city, :county
      t.float :rate
      t.timestamps
    end
    
    create_table :sessions do |t|
      t.string :session_id, :null => false
      t.text :data
      t.timestamps
    end

    add_index :sessions, :session_id
    add_index :sessions, :updated_at

    create_table :solar_ratings do |t|
      t.float :lat, :lng, :distance, :jan, :feb, :mar, :apr, :may, :jun, :jul, :aug, :sep, :oct, :nov, :dec, :annual
      t.string :potential
    end
    
    create_table :solutions do |t|
      t.integer :profile_id, :lead_id, :quote_id, :partner_id, :photovoltaic_module_id, :number_of_modules, :photovoltaic_inverter_id, :number_of_inverters
      t.float :system_price, :installation_estimate
      t.string :disposition 
      t.text :comments 
      t.timestamps
    end
    
    create_table :tariffs do |t|
      t.integer :utility_id
      t.string :description, :region
      t.timestamps
    end

    create_table :tiers do |t|
      t.string :type
      t.integer :tariff_id
      t.string :season
      t.float :min_usage, :max_usage, :rate
      t.timestamps
    end

    create_table :users do |t|
      t.integer :cec_company_id
      t.integer :company_id
      t.string :type
      t.string :hashed_password, :reset_password_key, :verification_code
      t.string :email, :name
      t.string :street_address, :city, :state, :postal_code
      t.string :phone_number, :fax_number
      t.boolean :first_login, :default => true
      t.boolean :company_administrator, :default => false
      t.boolean :can_update_company_profile, :default => false
      t.boolean :can_submit_quotes, :default => false
      t.boolean :can_purchase_leads, :default => false
  		t.boolean :waiting_approval, :default => true
      t.float :lat, :lng, :distance
      t.string :time_zone
  		t.datetime :verified_at
      t.timestamps
    end

    create_table :utilities do |t|
      t.string :name, :state, :utility_id, :region_map
      t.float :rate, :jan, :feb, :mar, :apr, :may, :jun, :jul, :aug, :sep, :oct, :nov, :dec
      t.integer :summer_starting_month, :summer_ending_month
      t.float :nox_rate, :so2_rate, :co2_rate, :mercury_rate
      t.float :percent_coal, :percent_oil, :percent_gas, :percent_nuclear, :percent_hydro, :percent_biomass, :percent_wind, :percent_solar, :percent_other, :percent_geothermal, :percent_unknown
      t.timestamps
    end
  end

  def self.down
    drop_table :utilities
    drop_table :users
    drop_table :tiers
    drop_table :tariffs
    drop_table :solutions
    drop_table :solar_ratings
    drop_table :sessions
    drop_table :sales_taxes
    drop_table :quotes
    drop_table :profiles
    drop_table :photovoltaic_modules
    drop_table :photovoltaic_inverters
    drop_table :login_tokens
    drop_table :leads
    drop_table :income_tax_brackets
    drop_table :incentives
    drop_table :discounts
    drop_table :companies
    drop_table :cec_companies
  end
end
