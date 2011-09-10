class AddMaskableToAdministrator < ActiveRecord::Migration
  def self.up
    add_column :users, :mask_id, :integer
    add_column :users, :mask_type, :string
    Customer::Deleted.update_columns
  end

  def self.down
    remove_column :users, :mask_type
    remove_column :users, :mask_id
    Customer::Deleted.update_columns
  end
end
