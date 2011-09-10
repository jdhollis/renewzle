class CreateCompanyBackgrounders < ActiveRecord::Migration
  def self.up
    create_table :company_backgrounders, :force => true do |t|
      t.integer :company_id
      t.integer :partner_id
      t.string :title
      t.string :doc
      t.datetime :created_at
      t.datetime :reviewed_at
      t.boolean :waiting_approval, :default => true
      t.boolean :approved, :default => false
      t.text :comments
    end
    
    add_column :users, :can_manage_company_backgrounders, :boolean, :default => false
  end

  def self.down
    remove_column :users, :can_manage_company_backgrounders
    drop_table :company_backgrounders
  end
end
