class AddPurchasePriceToLeads < ActiveRecord::Migration
  def self.up
    add_column 'leads', 'selling_price_currency', :string, :limit => 3, :default => 'USD'
    add_column 'leads', 'selling_price_cents', :integer, :default => 0
    Lead::Deleted.update_columns
  end

  def self.down
    remove_column 'leads', 'selling_price_cents'
    remove_column 'leads', 'selling_price_currency'
    Lead::Deleted.update_columns
  end
end
