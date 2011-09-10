class AddApprovedToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :approved, :boolean

    Profile.find_all_by_rfq(true).each do |profile|
      profile.approved = true
      profile.save(false)
    end
  end

  def self.down
    remove_column :profiles, :approved
  end
end
