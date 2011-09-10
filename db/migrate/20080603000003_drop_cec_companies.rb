class DropCecCompanies < ActiveRecord::Migration
  def self.up
    cec_companies = CecCompany.find(:all)
    cec_companies.each do |cec_company|
      if company = Company.find_by_name(cec_company.name)
        [ :name, :email, :url, :street_address, :city, :state, :postal_code, :country, :phone_number, :fax_number, :installs ].each do |attr|
          company.update_attribute("cec_#{attr}", cec_company.send(attr))
        end
      else
        attributes = {}
        [ :name, :email, :url, :street_address, :city, :state, :postal_code, :country, :phone_number, :fax_number, :installs ].each do |attr|
          attributes["cec_#{attr}"] = cec_company.send(attr)
        end
        company = Company.new(attributes)
        company.save(false)
      end
    end
    
    drop_table :cec_companies
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, "Can't recover the deleted CEC companies"
  end
end
