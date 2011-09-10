class CreateQuoteTemplates < ActiveRecord::Migration
  def self.up
    create_table :quote_templates do |t|
      t.integer :partner_id, :photovoltaic_module_id, :number_of_modules, :photovoltaic_inverter_id, :number_of_inverters
      t.string :description
      t.float :system_price, :installation_estimate
      t.boolean :installation_available, :default => true
      t.boolean :will_accept_rebate_assignment, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :quote_templates
  end
end
