# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080912080444) do

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "url"
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.string   "postal_code"
    t.string   "country"
    t.string   "phone_number"
    t.string   "fax_number"
    t.float    "lat"
    t.float    "lng"
    t.float    "distance"
    t.boolean  "geocodable"
    t.boolean  "installs"
    t.boolean  "claimed",                    :default => false
    t.string   "total_kw_installed"
    t.string   "contractors_license_number"
    t.string   "in_business_since"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cec_name"
    t.string   "cec_email"
    t.string   "cec_url"
    t.string   "cec_street_address"
    t.string   "cec_city"
    t.string   "cec_state"
    t.string   "cec_postal_code"
    t.string   "cec_country"
    t.string   "cec_phone_number"
    t.string   "cec_fax_number"
    t.boolean  "cec_installs"
  end

  create_table "companies_geo_regions", :id => false, :force => true do |t|
    t.integer "company_id",    :limit => 8
    t.integer "geo_region_id", :limit => 8
  end

  create_table "company_backgrounders", :force => true do |t|
    t.integer  "company_id",       :limit => 8
    t.integer  "partner_id",       :limit => 8
    t.string   "title"
    t.string   "doc"
    t.datetime "created_at"
    t.datetime "reviewed_at"
    t.boolean  "waiting_approval",              :default => true
    t.boolean  "approved",                      :default => false
    t.text     "comments"
  end

  create_table "deleted_companies", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "url"
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.string   "postal_code"
    t.string   "country"
    t.string   "phone_number"
    t.string   "fax_number"
    t.float    "lat"
    t.float    "lng"
    t.float    "distance"
    t.boolean  "geocodable"
    t.boolean  "installs"
    t.boolean  "claimed"
    t.string   "total_kw_installed"
    t.string   "contractors_license_number"
    t.string   "in_business_since"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cec_name"
    t.string   "cec_email"
    t.string   "cec_url"
    t.string   "cec_street_address"
    t.string   "cec_city"
    t.string   "cec_state"
    t.string   "cec_postal_code"
    t.string   "cec_country"
    t.string   "cec_phone_number"
    t.string   "cec_fax_number"
    t.boolean  "cec_installs"
    t.datetime "deleted_at"
  end

  create_table "deleted_leads", :force => true do |t|
    t.integer  "partner_id",             :limit => 8
    t.integer  "quote_id",               :limit => 8
    t.string   "confirmation_number"
    t.string   "authorization"
    t.string   "ip_address"
    t.string   "discount"
    t.boolean  "purchased"
    t.boolean  "closed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "selling_price_currency"
    t.integer  "selling_price_cents"
  end

  create_table "deleted_profiles", :force => true do |t|
    t.integer  "customer_id",                   :limit => 8
    t.integer  "utility_id",                    :limit => 8
    t.integer  "solar_rating_id",               :limit => 8
    t.integer  "federal_income_tax_bracket_id", :limit => 8
    t.integer  "state_income_tax_bracket_id",   :limit => 8
    t.integer  "lead_id",                       :limit => 8
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.string   "postal_code"
    t.float    "average_monthly_bill"
    t.float    "annual_interest_rate"
    t.float    "percentage_to_offset"
    t.integer  "loan_term",                     :limit => 8
    t.boolean  "rfq"
    t.boolean  "second_chance"
    t.string   "filing_status"
    t.float    "income"
    t.string   "region"
    t.float    "system_performance_derate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "approved"
    t.integer  "geo_region_id",                 :limit => 8
    t.datetime "deleted_at"
  end

  create_table "deleted_quote_templates", :force => true do |t|
    t.integer  "partner_id",                    :limit => 8
    t.integer  "photovoltaic_module_id",        :limit => 8
    t.integer  "number_of_modules",             :limit => 8
    t.integer  "photovoltaic_inverter_id",      :limit => 8
    t.integer  "number_of_inverters",           :limit => 8
    t.string   "description"
    t.float    "system_price"
    t.float    "installation_estimate"
    t.boolean  "installation_available"
    t.boolean  "will_accept_rebate_assignment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_backgrounder_id",       :limit => 8
    t.datetime "deleted_at"
  end

  create_table "deleted_quotes", :force => true do |t|
    t.integer  "profile_id",                    :limit => 8
    t.integer  "partner_id",                    :limit => 8
    t.integer  "photovoltaic_module_id",        :limit => 8
    t.integer  "number_of_modules",             :limit => 8
    t.integer  "photovoltaic_inverter_id",      :limit => 8
    t.integer  "number_of_inverters",           :limit => 8
    t.float    "system_price"
    t.float    "installation_estimate"
    t.boolean  "installation_available"
    t.boolean  "will_accept_rebate_assignment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_backgrounder_id",       :limit => 8
    t.datetime "deleted_at"
  end

  create_table "deleted_solutions", :force => true do |t|
    t.integer  "profile_id",               :limit => 8
    t.integer  "lead_id",                  :limit => 8
    t.integer  "quote_id",                 :limit => 8
    t.integer  "partner_id",               :limit => 8
    t.integer  "photovoltaic_module_id",   :limit => 8
    t.integer  "number_of_modules",        :limit => 8
    t.integer  "photovoltaic_inverter_id", :limit => 8
    t.integer  "number_of_inverters",      :limit => 8
    t.float    "system_price"
    t.float    "installation_estimate"
    t.string   "disposition"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "deleted_users", :force => true do |t|
    t.integer  "cec_company_id",                   :limit => 8
    t.integer  "company_id",                       :limit => 8
    t.string   "type"
    t.string   "hashed_password"
    t.string   "password_reset_key"
    t.string   "verification_code"
    t.string   "email"
    t.string   "first_name"
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.string   "postal_code"
    t.string   "phone_number"
    t.string   "fax_number"
    t.boolean  "first_login"
    t.boolean  "company_administrator"
    t.boolean  "can_update_company_profile"
    t.boolean  "can_submit_quotes"
    t.boolean  "can_purchase_leads"
    t.boolean  "waiting_approval"
    t.float    "lat"
    t.float    "lng"
    t.float    "distance"
    t.string   "time_zone"
    t.datetime "verified_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "last_name"
    t.boolean  "can_manage_company_backgrounders"
    t.boolean  "can_manage_counties"
    t.datetime "deleted_at"
    t.string   "mask_type"
    t.integer  "mask_id",                          :limit => 8
  end

  create_table "discounts", :force => true do |t|
    t.integer  "company_id", :limit => 8
    t.string   "type"
    t.float    "price"
    t.float    "percentage"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "geo_cities", :force => true do |t|
    t.integer "geo_region_id", :limit => 8
    t.string  "city_name"
    t.string  "postal_code"
  end

  add_index "geo_cities", ["geo_region_id"], :name => "index_geo_cities_on_geo_region_id"

  create_table "geo_counties", :force => true do |t|
    t.string "postal_code"
    t.string "city_name"
    t.string "county_name"
    t.string "state_code"
  end

  create_table "geo_regions", :force => true do |t|
    t.integer "geo_state_id", :limit => 8
    t.string  "region_name"
  end

  add_index "geo_regions", ["geo_state_id"], :name => "index_geo_regions_on_geo_state_id"

  create_table "geo_states", :force => true do |t|
    t.string "state_code"
  end

  create_table "incentives", :force => true do |t|
    t.string   "type"
    t.string   "city"
    t.string   "state"
    t.string   "source"
    t.string   "description"
    t.string   "notes"
    t.integer  "utility_id",          :limit => 8
    t.boolean  "derate",                           :default => false
    t.float    "rate"
    t.float    "minimum_system_size"
    t.float    "maximum_system_size"
    t.float    "maximum_amount"
    t.float    "maximum_percentage"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "income_tax_brackets", :force => true do |t|
    t.string   "type"
    t.string   "state"
    t.string   "filing_status"
    t.float    "income_min"
    t.float    "income_max"
    t.float    "rate"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "leads", :force => true do |t|
    t.integer  "partner_id",             :limit => 8
    t.integer  "quote_id",               :limit => 8
    t.string   "confirmation_number"
    t.string   "authorization"
    t.string   "ip_address"
    t.string   "discount"
    t.boolean  "purchased",                           :default => false
    t.boolean  "closed",                              :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "selling_price_currency", :limit => 3, :default => "USD"
    t.integer  "selling_price_cents",                 :default => 0
  end

  create_table "login_tokens", :force => true do |t|
    t.integer  "user_id",    :limit => 8
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photovoltaic_inverters", :force => true do |t|
    t.string   "manufacturer"
    t.string   "model_number"
    t.text     "description"
    t.integer  "power_rating",        :limit => 8
    t.float    "weighted_efficiency"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photovoltaic_modules", :force => true do |t|
    t.string   "manufacturer"
    t.string   "model_number"
    t.text     "description"
    t.float    "stc_rating"
    t.float    "ptc_rating"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", :force => true do |t|
    t.integer  "customer_id",                   :limit => 8
    t.integer  "utility_id",                    :limit => 8
    t.integer  "solar_rating_id",               :limit => 8
    t.integer  "federal_income_tax_bracket_id", :limit => 8
    t.integer  "state_income_tax_bracket_id",   :limit => 8
    t.integer  "lead_id",                       :limit => 8
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.string   "postal_code"
    t.float    "average_monthly_bill"
    t.float    "annual_interest_rate",                       :default => 0.06
    t.float    "percentage_to_offset",                       :default => 1.0
    t.integer  "loan_term",                     :limit => 8, :default => 25
    t.boolean  "rfq",                                        :default => false
    t.boolean  "second_chance",                              :default => false
    t.string   "filing_status",                              :default => "Married"
    t.float    "income",                                     :default => 100000.0
    t.string   "region"
    t.float    "system_performance_derate",                  :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "approved"
    t.integer  "geo_region_id",                 :limit => 8
  end

  add_index "profiles", ["geo_region_id"], :name => "index_profiles_on_geo_region_id"

  create_table "quote_templates", :force => true do |t|
    t.integer  "partner_id",                    :limit => 8
    t.integer  "photovoltaic_module_id",        :limit => 8
    t.integer  "number_of_modules",             :limit => 8
    t.integer  "photovoltaic_inverter_id",      :limit => 8
    t.integer  "number_of_inverters",           :limit => 8
    t.string   "description"
    t.float    "system_price"
    t.float    "installation_estimate"
    t.boolean  "installation_available",                     :default => true
    t.boolean  "will_accept_rebate_assignment",              :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_backgrounder_id",       :limit => 8
  end

  create_table "quotes", :force => true do |t|
    t.integer  "profile_id",                    :limit => 8
    t.integer  "partner_id",                    :limit => 8
    t.integer  "photovoltaic_module_id",        :limit => 8
    t.integer  "number_of_modules",             :limit => 8
    t.integer  "photovoltaic_inverter_id",      :limit => 8
    t.integer  "number_of_inverters",           :limit => 8
    t.float    "system_price"
    t.float    "installation_estimate"
    t.boolean  "installation_available",                     :default => true
    t.boolean  "will_accept_rebate_assignment",              :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_backgrounder_id",       :limit => 8
  end

  add_index "quotes", ["company_backgrounder_id"], :name => "index_quotes_on_company_backgrounder_id"

  create_table "sales_taxes", :force => true do |t|
    t.string   "city"
    t.string   "county"
    t.float    "rate"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "solar_ratings", :force => true do |t|
    t.float  "lat"
    t.float  "lng"
    t.float  "distance"
    t.float  "jan"
    t.float  "feb"
    t.float  "mar"
    t.float  "apr"
    t.float  "may"
    t.float  "jun"
    t.float  "jul"
    t.float  "aug"
    t.float  "sep"
    t.float  "oct"
    t.float  "nov"
    t.float  "dec"
    t.float  "annual"
    t.string "potential"
  end

  create_table "solutions", :force => true do |t|
    t.integer  "profile_id",               :limit => 8
    t.integer  "lead_id",                  :limit => 8
    t.integer  "quote_id",                 :limit => 8
    t.integer  "partner_id",               :limit => 8
    t.integer  "photovoltaic_module_id",   :limit => 8
    t.integer  "number_of_modules",        :limit => 8
    t.integer  "photovoltaic_inverter_id", :limit => 8
    t.integer  "number_of_inverters",      :limit => 8
    t.float    "system_price"
    t.float    "installation_estimate"
    t.string   "disposition"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tariffs", :force => true do |t|
    t.integer  "utility_id",  :limit => 8
    t.string   "description"
    t.string   "region"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tiers", :force => true do |t|
    t.string   "type"
    t.integer  "tariff_id",  :limit => 8
    t.string   "season"
    t.float    "min_usage"
    t.float    "max_usage"
    t.float    "rate"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.integer  "cec_company_id",                   :limit => 8
    t.integer  "company_id",                       :limit => 8
    t.string   "type"
    t.string   "hashed_password"
    t.string   "password_reset_key"
    t.string   "verification_code"
    t.string   "email"
    t.string   "first_name"
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.string   "postal_code"
    t.string   "phone_number"
    t.string   "fax_number"
    t.boolean  "first_login",                                   :default => true
    t.boolean  "company_administrator",                         :default => false
    t.boolean  "can_update_company_profile",                    :default => false
    t.boolean  "can_submit_quotes",                             :default => false
    t.boolean  "can_purchase_leads",                            :default => false
    t.boolean  "waiting_approval",                              :default => true
    t.float    "lat"
    t.float    "lng"
    t.float    "distance"
    t.string   "time_zone"
    t.datetime "verified_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "last_name"
    t.boolean  "can_manage_company_backgrounders",              :default => false
    t.boolean  "can_manage_counties",                           :default => true
    t.integer  "mask_id",                          :limit => 8
    t.string   "mask_type"
  end

  create_table "utilities", :force => true do |t|
    t.string   "name"
    t.string   "state"
    t.string   "utility_id"
    t.string   "region_map"
    t.float    "rate"
    t.float    "jan"
    t.float    "feb"
    t.float    "mar"
    t.float    "apr"
    t.float    "may"
    t.float    "jun"
    t.float    "jul"
    t.float    "aug"
    t.float    "sep"
    t.float    "oct"
    t.float    "nov"
    t.float    "dec"
    t.integer  "summer_starting_month", :limit => 8
    t.integer  "summer_ending_month",   :limit => 8
    t.float    "nox_rate"
    t.float    "so2_rate"
    t.float    "co2_rate"
    t.float    "mercury_rate"
    t.float    "percent_coal"
    t.float    "percent_oil"
    t.float    "percent_gas"
    t.float    "percent_nuclear"
    t.float    "percent_hydro"
    t.float    "percent_biomass"
    t.float    "percent_wind"
    t.float    "percent_solar"
    t.float    "percent_other"
    t.float    "percent_geothermal"
    t.float    "percent_unknown"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
