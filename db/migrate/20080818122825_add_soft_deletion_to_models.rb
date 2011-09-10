class AddSoftDeletionToModels < ActiveRecord::Migration
  def self.up
    Company::Deleted.create_table
    Customer::Deleted.create_table  # Customer and Partner both use soft deletion, but they share the same table. The plugin errors out if I try to create_table on both.
    Lead::Deleted.create_table
    Profile::Deleted.create_table
    Quote::Deleted.create_table
    QuoteTemplate::Deleted.create_table
    Solution::Deleted.create_table
  end

  def self.down
    Company::Deleted.drop_table
    Customer::Deleted.drop_table  # Customer and Partner both use soft deletion, but they share the same table. The plugin errors out if I try to drop_table on both.
    Lead::Deleted.drop_table
    Profile::Deleted.drop_table
    Quote::Deleted.drop_table
    QuoteTemplate::Deleted.drop_table
    Solution::Deleted.drop_table
  end
end
