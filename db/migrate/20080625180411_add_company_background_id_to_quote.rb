class AddCompanyBackgroundIdToQuote < ActiveRecord::Migration
  def self.up
    add_column :quotes, :company_backgrounder_id, :integer
    add_index :quotes, :company_backgrounder_id
  end

  def self.down
    remove_column :quotes, :company_backgrounder_id
  end
end
