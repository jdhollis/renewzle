class AddCompanyBackgrounderIdToQuoteTemplates < ActiveRecord::Migration
  def self.up
    add_column :quote_templates, :company_backgrounder_id, :integer
  end

  def self.down
    remove_column :quote_templates, :company_backgrounder_id, :integer
  end
end
