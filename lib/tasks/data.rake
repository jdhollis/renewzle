# I had to replicate this vendor/gem loading code (plus add the paths into $LOAD_PATH) so that fastercsv and dbf will load whether or not they are installed system-wide. Rake tasks seem to get loaded before Rails does it's $LOAD_PATH magic, so here we are.

load_paths = Dir["#{RAILS_ROOT}/vendor/gems/**"].map do |dir| 
  File.directory?(lib = "#{dir}/lib") ? lib : dir
end
load_paths.reverse_each { |dir| $LOAD_PATH.unshift(dir) if File.directory?(dir) }
$LOAD_PATH.uniq!

require 'fastercsv'
require 'dbf'
require 'uri'
require 'net/http'
require 'fileutils'

namespace :data do
  namespace :load do
    desc 'Load everything except CEC companies and LATILT'
    task :all => [ :sales_tax, :utilities, :region_maps, :tariffs, :modules, :inverters, :incentives, :tax_brackets, :admins, "data:destroy:utilities_without_a_tariff", :geo ]
    
    desc 'Load LATILT data from a DBF file into the SolarRatings table, converting gridcodes to lng/lat pairs'
    task :latilt => :environment do
      from = ENV.include?('from') ? ENV['from'] : "#{RAILS_ROOT}/vendor/data/latilt.dbf"
      puts "Loading solar ratings from #{from}..."
      
      #
      # TODO: Looking at the new DBF API, there may be some ways to simplify the following code.
      #
      
      table = DBF::Table.new(from, :in_memory => false)
      record_count = table.record_count
      
      0.upto(record_count - 1) do |i|
        params = { }
        
        record = table.record(i)
        gridcode = record.attributes['GRIDCODE'].to_s
        
        case gridcode.length
        when 8
          lng = gridcode[0..3]
          lat = gridcode[4..7]
        when 9
          lng = gridcode[0..4]
          lat = gridcode[5..8]
        end
        
        params[:lng] = lng.to_f / -100
        params[:lat] = lat.to_f / 100
        
        [ :jan, :feb, :mar, :apr, :may, :jun, :jul, :aug, :sep, :oct, :nov, :dec, :annual ].each do |per|
          params[per] = record.attributes[per.to_s.upcase]
        end
        
        params[:potential] = record.attributes['POTENTIAL'].strip
        
        SolarRating.create!(params)
        puts "  #{i+1} of #{record_count}: #{gridcode} loaded"
      end
      
      puts 'Done!'
    end
    
    desc 'Load utilities (including associated rate and load data) from a CSV file'
    task :utilities => :environment do
      from = ENV.include?('from') ? ENV['from'] : "#{RAILS_ROOT}/vendor/data/utilities.csv"
      puts "Loading utilities from #{from}..."
      
      FasterCSV.foreach(from, { :headers => true }) do |row|
        attributes = row.to_hash
        next if attributes['state'] != "CA"
        Utility.create!(attributes)
        puts "  #{attributes['name']} for #{attributes['state']} loaded"
      end
      
      puts "Done!"
    end

    desc 'Set region maps for specific utilities'
    task :region_maps => :environment do
      puts 'Setting region maps ...'
      { 'sce' => 'Southern California Edison Co',
        'pge' => 'Pacific Gas & Electric Co',
        'sdge' => 'San Diego Gas & Electric Co'
      }.each do |abbr,name|
        puts "Setting #{name} ..."
        u = Utility.find_by_name(name)
        u.region_map = "#{abbr}.jpg"
        u.save
      end
    end
    
    desc 'Load tariffs from a CSV file'
    task :tariffs => :environment do
      from = ENV.include?('from') ? ENV['from'] : "#{RAILS_ROOT}/vendor/data/tariffs.csv"
      puts "Loading tariffs from #{from}..."
      
      FasterCSV.foreach(from, { :headers => true }) do |row|
        attributes = row.to_hash
        if utility = Utility.find_by_utility_id(attributes['utility_id'])
          unless tariff = utility.tariffs.find_by_description_and_region(attributes['description'], attributes['region'])
            tariff = Tariff.create!({ :utility => utility, :description => attributes['description'], :region => attributes['region'] })
          end
          
          case attributes['type']
          when 'Minimum'
            tier_class = MinimumTier
          when 'Fixed'
            tier_class = FixedTier
          when 'TieredFixed'
            tier_class = TieredFixedTier
          when 'Variable'
            tier_class = VariableTier
          end
          
          tier = tier_class.create!({ :tariff => tariff, :season => attributes['season'], :min_usage => attributes['min_usage'], :max_usage => attributes['max_usage'], :rate => attributes['rate'] })
          
          puts "  #{attributes['utility_name']}: #{attributes['description']} #{attributes['region']} #{attributes['season']} #{attributes['type']} from #{attributes['min_usage']} to #{attributes['max_usage']} loaded"
        else
          raise "Could not find #{attributes['utility_id']} - #{attributes['utility_name']}"
        end
      end
      
      puts "Done!"
    end
    
    desc 'Load PV modules from a CSV file'
    task :modules => :environment do
      from = ENV.include?('from') ? ENV['from'] : "#{RAILS_ROOT}/vendor/data/photovoltaic_modules.csv"
      puts "Loading PV modules from #{from}..."
      
      FasterCSV.foreach(from, { :headers => true }) do |row|
        attributes = row.to_hash
        PhotovoltaicModule.create!(attributes)
        puts "  #{attributes['model_number']} loaded"
      end
      
      puts "Done!"
    end
    
    desc 'Load PV inverters from a CSV file'
    task :inverters => :environment do
      from = ENV.include?('from') ? ENV['from'] : "#{RAILS_ROOT}/vendor/data/photovoltaic_inverters.csv"
      puts "Loading PV inverters from #{from}..."
      
      FasterCSV.foreach(from, { :headers => true }) do |row|
        attributes = row.to_hash
        PhotovoltaicInverter.create!(attributes)
        puts "  #{attributes['model_number']} loaded"
      end
      
      puts "Done!"
    end
    
    desc 'Load incentives from a CSV file'
    task :incentives => :environment do
      from = ENV.include?('from') ? ENV['from'] : "#{RAILS_ROOT}/vendor/data/incentives.csv"
      puts "Loading incentives from #{from}..."
      
      FasterCSV.foreach(from, { :headers => true }) do |row|
        attributes = row.to_hash
        
        attributes['city'] = attributes.delete('applicability')
        
        if utility_id = attributes.delete('utility_id')
          if utility = Utility.find_by_utility_id(utility_id)
            attributes['utility_id'] = utility.id
          end
        end
        
        case attributes.delete('type')
        when "Percentage"
          PercentageOfProjectCostIncentive.create!(attributes)
        when "Lump Sum"
          LumpSumIncentive.create!(attributes)
        when "Exemption"
          ExemptionIncentive.create!(attributes)
        when "per kWh"
          PerKwhIncentive.create!(attributes)
        when "per CEC W"
          PerCecWattIncentive.create!(attributes)
        when "per Nameplate W"
          PerNameplateWattIncentive.create!(attributes)
        else
          raise "Unrecognized incentive type"
        end
        
        puts "  #{attributes['description']} loaded"
      end
      
      puts "Done!"
    end
    
    desc "Load sales tax rates from a CSV file"
    task :sales_tax => :environment do
      from = ENV.include?('from') ? ENV['from'] : "#{RAILS_ROOT}/vendor/data/sales_tax_rates.csv"
      
      puts "Loading sales tax rates from #{from}..."
      
      FasterCSV.foreach(from, { :headers => true }) do |row|
        attributes = row.to_hash
        attributes["rate"] = attributes["rate"].to_f / 100.0
        SalesTax.create!(attributes)
        puts "  #{attributes['city']} #{attributes['rate']} loaded"
      end
      
      puts "Done!"
    end
    
    desc 'Load tax brackets from a CSV file'
    task :tax_brackets => :environment do
      from = ENV.include?('from') ? ENV['from'] : "#{RAILS_ROOT}/vendor/data/income_tax_brackets.csv"
      puts "Loading tax brackets from #{from}..."
      
      FasterCSV.foreach(from, { :headers => true }) do |row|
        attributes = row.to_hash
        
        level = attributes.delete('level')
        case level
        when 'Federal':
          FederalIncomeTaxBracket.create!(attributes)
          description = level
        when 'State':
          StateIncomeTaxBracket.create!(attributes)
          description = attributes['state']
        end
        
        puts "  #{description} #{attributes['filing_status']} #{attributes['income_min']} - #{attributes['income_max']} at #{attributes['rate']} loaded"
      end
      
      puts "Done!"
    end

    desc 'Load CEC Companies from a CSV file'
    task :cec_companies => :environment do
      from = ENV.include?('from') ? ENV['from'] : "#{RAILS_ROOT}/vendor/data/cec_companies.csv"
      puts "Loading companies from #{from}..."
      FasterCSV.foreach(from, { :headers => true }) do |row|
        attributes = row.to_hash
        if Company.find_by_cec_name(attributes['cec_name'])
          puts "  #{attributes['cec_name']} already exists"
        else
          attributes['cec_country'] = 'Canada' if [ 'Alberta', 'British Columbia', 'Manitoba', 'New Brunswick', 'Newfoundland and Labrador', 'Northwest Territories', 'Nova Scotia', 'Nunavut', 'Ontario', 'Prince Edward Island', 'Quebec', 'Saskatchewan', 'Yukon Territory' ].include?(attributes['cec_state'])
          attributes['cec_country'] = 'United States' unless attributes['cec_country']
          company = Company.new
          company.cec_name = attributes['cec_name']
          company.cec_street_address = attributes['cec_street_address']
          company.cec_city = attributes['cec_city']
          company.cec_state = attributes['cec_state']
          company.cec_postal_code = attributes['cec_postal_code']
          company.cec_country = attributes['cec_country']
          company.cec_phone_number = attributes['cec_phone_number']
          company.cec_fax_number = attributes['cec_fax_number']
          company.cec_url = attributes['cec_url']
          company.cec_email = attributes['cec_email']
          company.save(false)
          puts "  #{attributes['cec_name']} loaded"
        end
      end
      puts "Done!"
    end

    desc 'Load admins from a CSV file'
    task :admins => :environment do
      from = ENV.include?('from') ? ENV['from'] : "#{RAILS_ROOT}/vendor/data/admins.csv"
      puts "Loading admins from #{from}..."
      Administrator.destroy_all
      FasterCSV.foreach(from, { :headers => true }) do |row|
        attributes = row.to_hash
        company = Administrator.create!(attributes)
        puts "  #{attributes['first_name']} #{attributes['last_name']} loaded"
      end
      puts "Done!"
    end
    
    desc 'Load GeoCounties, GeoStates, GeoRegions, and GeoCities'
    task :geo => :environment do
      from = ENV.include?('from') ? ENV['from'] : "#{RAILS_ROOT}/vendor/data/geo_counties.csv"
      puts "Loading GeoCounties from #{from}..."
      
      FasterCSV.foreach(from, { :headers => true }) do |row|
        attributes = row.to_hash
        next if attributes['state_code'] != 'CA'
        geo_county = GeoCounty.create!(attributes)
        puts "  #{attributes['postal_code']} #{attributes['city_name']} #{attributes['county_name']} #{attributes['state_code']} loaded"
      end
      
      puts "  Creating GeoStates, GeoRegions, and GeoCities from GeoCounties"
      
      GeoCounty.find(:all).each do |record|
        geo_state = GeoState.find_or_create_by_state_code(record.state_code)
        if geo_state.new_record?
          geo_state.save!
        end

        geo_region = geo_state.geo_regions.find_or_create_by_region_name(record.county_name)
        geo_region.save! if geo_region.new_record?

        geo_city = geo_region.geo_cities.find(:first, :conditions => { :city_name => record.city_name, :postal_code => record.postal_code, :geo_region_id => geo_region.id})
        if geo_city.blank?
          geo_city = GeoCity.create(:city_name => record.city_name, :postal_code => record.postal_code, :geo_region_id => geo_region.id)
          geo_city.save!
        end
      end
      
      puts "Done!"
    end
  end
  
  namespace :update do
    desc 'Update utilities data from a CSV file'
    task :utilities => :environment do
      from = ENV.include?('from') ? ENV['from'] : "#{RAILS_ROOT}/vendor/data/updated_utilities.csv"
      puts "Updating utilities from #{from}..."
      
      FasterCSV.foreach(from, { :headers => true }) do |row|
        attributes = row.to_hash
        if utility = Utility.find_by_utility_id(attributes['utility_id'])
          utility.attributes = attributes
          utility.save!
          puts "  #{attributes['name']} updated"
        end
      end
      
      puts "Done!"
    end
  end
  
  namespace :download do
    desc 'Download and parse CEC Companies'
    task :cec_companies => :environment do
      puts "Downloading CEC Companies Data..."
      url = "http://www.consumerenergycenter.org/erprebate/database/fulllist.php"
      page = Net::HTTP.get_response(URI.parse(url).host, URI.parse(url).path).body
      
      puts "Parsing CEC Companies Data..."
      FileUtils.touch("#{RAILS_ROOT}/vendor/data/cec_companies.csv")
      File.open("#{RAILS_ROOT}/vendor/data/cec_companies.csv", "w") do |f|
      	f << "cec_name,cec_street_address,cec_city,cec_state,cec_postal_code,cec_phone_number,cec_fax_number,cec_email,cec_url,cec_installs\n"
      	page.scan(/<table.*?>(.*?)<\/table>/).each do |company|
      		matches = /<b>Company<\/b><br>(.*?)<br>(.*?)<br>(.*?)<br>(.*?), (\w+) +?(\d{5}|\w{6})(-(\d{4}))?<\/td><td class='text'><b>Phone: <\/b>(.*?)<br><b>Fax:<\/b>(.*?)<br><b>Email:<\/b>(.*?)<br><b>Web:<\/b>(.*?)<br><b>Install:<\/b>(.*?)<\/td>/.match(company.to_s)
      		begin
            remove_underscores = Proc.new { |s| s.strip.gsub('_', '').gsub('"', '') }
            quote = Proc.new { |s| "\"#{s}\"" }
            format_url = Proc.new do |url|
              unless url.blank?
                url = "http://#{url}" unless url =~ /http\:\/\//
                url = "#{url}/" unless url =~ /\/$/
                url 
              end
            end

            record = []
            record << quote.call(remove_underscores.call(matches[1])) # Company
            record << quote.call(remove_underscores.call("#{matches[2]} #{matches[3]}")) # Address
            record << quote.call(remove_underscores.call(matches[4])) # City
            record << quote.call(remove_underscores.call(matches[5])) # State
            record << quote.call(remove_underscores.call(matches[6])) # Postal Code
            record << quote.call(remove_underscores.call(matches[9])) # Phone
            record << quote.call(remove_underscores.call(matches[10])) # Fax
            record << quote.call(remove_underscores.call(matches[11])) # Email
            record << quote.call(format_url.call(remove_underscores.call(matches[12]))) # URL
            record << ((quote.call(remove_underscores.call(matches[13])) == '"Yes"') ? 1 : 0) # Installs

            f << record.join(',') 
      			f << "\n"
      		rescue
            puts "  An error occurred: #{$!}"
      			puts "  Can't process company string:\n#{company}"
            exit
      		end
      	end
      end
      puts "Done!"
    end
  end
  
  namespace :destroy do
    desc "Destroy all non-California utilities"
    task :non_california_utilities => :environment do
      puts "Destroying all non-California utilities..."
      number_destroyed = Utility.destroy_all([ "state != ?", "CA" ]).size
      puts "#{number_destroyed} utilities destroyed!"
    end
    
    desc "Destroy all utilities that don't have a tariff"
    task :utilities_without_a_tariff => :environment do
      puts "Destroying all utilities that don't have a tariff..."
      utilities = Utility.find(:all)
      number_destroyed = 0
      utilities.each do |u|
        if u.tariffs.blank?
          u.destroy
          number_destroyed = number_destroyed + 1
        end
      end
      puts "#{number_destroyed} utilities destroyed!"
    end
  end
end
