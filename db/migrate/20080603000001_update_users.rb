class UpdateUsers < ActiveRecord::Migration
  def self.up
    execute("UPDATE users SET type = 'Administrator' WHERE type = 'Admin'")
    rename_column :users, :reset_password_key, :password_reset_key

    rename_column :users, :name, :first_name
    add_column :users, :last_name, :string
    
    User.reset_column_information
    
    users = User.find(:all)
    users.each do |user|
      first_name, last_name = user.first_name.split
      last_name = last_name.blank? ? 'LAST NAME' : last_name
      user.update_attribute(:first_name, first_name)
      user.update_attribute(:last_name, last_name)
    end
  end

  def self.down
    execute("UPDATE users SET type = 'Admin' WHERE type = 'Administrator'")
    users = User.find(:all)
    users.each do |user|
      name = user.first_name
      name = "#{name} #{user.last_name}" unless user.last_name == 'LAST NAME'
      user.update_attribute(:first_name, name)
    end
    
    drop_column :users, :last_name
    rename_column :users, :first_name, :name
    
    rename_column :users, :password_reset_key, :reset_password_key
  end
end
