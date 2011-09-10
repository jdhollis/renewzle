class UpdateCompanies < ActiveRecord::Migration
  def self.up
    change_column :companies, :claimed, :boolean, :default => false
    remove_column :companies, :cec_company_hash
    
    add_column :companies, :cec_name, :string
    add_column :companies, :cec_email, :string
    add_column :companies, :cec_url, :string
    add_column :companies, :cec_street_address, :string
    add_column :companies, :cec_city, :string
    add_column :companies, :cec_state, :string
    add_column :companies, :cec_postal_code, :string
    add_column :companies, :cec_country, :string
    add_column :companies, :cec_phone_number, :string
    add_column :companies, :cec_fax_number, :string
    add_column :companies, :cec_installs, :boolean
  end

  def self.down
    remove_column :companies, :cec_installs
    remove_column :companies, :cec_fax_number
    remove_column :companies, :cec_phone_number
    remove_column :companies, :cec_country
    remove_column :companies, :cec_postal_code
    remove_column :companies, :cec_state
    remove_column :companies, :cec_city
    remove_column :companies, :cec_street_address
    remove_column :companies, :cec_url
    remove_column :companies, :cec_email
    remove_column :companies, :cec_name
    
    add_column :companies, :cec_company_hash
    change_column :companies, :claimed, :boolean
  end
end
