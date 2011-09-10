namespace :maintenance do
  namespace :cleanup do
    desc 'Remove Unowned Profiles that have not been updated in the past three months.'
    task :profiles => :environment do
      puts "Removing Unowned Profiles"
			Profile.find_all_unowned.each do |p|
				p.destroy unless p.updated_at > Time.now - 3.months
			end
      puts 'Done!'
    end

    desc 'Update Candian provinces to use their equivalent abbreviations.'
    task :companies => :environment do
      { 'Alberta' => 'AB', 'British Columbia' => 'BC', 'Manitoba' => 'MB', 'New Brunswick' => 'NB', 'Newfoundland' => 'NL', 'Labrador' => 'NL', 'Northwest Territories' => 'NT', 'Nova Scotia' => 'NS', 'Nunavut' => 'NU', 'Ontario' => 'ON', 'Prince Edward Island' => 'PE', 'Quebec' => 'QC', 'Saskatchewan' => 'SK', 'Yukon' => 'YT' }.each do |province, abbrv|
        puts "Updating companies with province '#{province}'"
        Company.find_all_by_state(province).each do |company|
          company.update_attribute('state', abbrv)
        end
        
        Company.find_all_by_cec_state(province).each do |company|
          company.update_attribute('cec_state', abbrv)
        end
      end
    end
    
    desc 'Convert City of Pasadena FixedTiers to TieredFixedTiers'
    task :pasadena => :environment do
      puts "Converting City of Pasadena FixedTiers to TieredFixedTiers"
      utility = Utility.find_by_name("City of Pasadena")
      tariff = utility.tariffs.first
      fixed_tiers = tariff.fixed_tiers
      fixed_tiers.each do |ft|
        ft.update_attribute('type', 'TieredFixedTier')
      end
      puts "Done!"
    end
	end
end
