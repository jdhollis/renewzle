# I had to replicate this vendor/gem loading code (plus add the paths into $LOAD_PATH) so that fastercsv and dbf will load whether or not they are installed system-wide. Rake tasks seem to get loaded before Rails does it's $LOAD_PATH magic, so here we are.

load_paths = Dir["#{RAILS_ROOT}/vendor/gems/**"].map do |dir| 
  File.directory?(lib = "#{dir}/lib") ? lib : dir
end
load_paths.reverse_each { |dir| $LOAD_PATH.unshift(dir) if File.directory?(dir) }
$LOAD_PATH.uniq!

require 'fileutils'

namespace :testing do
  namespace :fixtures do
    desc "Generate test fixtures from data loaded into the development environment"
    task :generate => :environment do
      puts "Generating..."
      
      #
      # Sales tax
      #
      
      sales_tax_file = "#{RAILS_ROOT}/spec/fixtures/sales_taxes.yml"
      FileUtils.touch(sales_tax_file)
      
      File.open(sales_tax_file, "w") do |f|
        [ "Pacifica" ].each do |city|
          sales_tax = SalesTax.find_by_city(city)
          f << sales_tax.to_yaml
        end
      end
      
      #
      # Solar ratings
      #
      
      solar_ratings_file = "#{RAILS_ROOT}/spec/fixtures/solar_ratings.yml"
      FileUtils.touch(solar_ratings_file)
      
      File.open(solar_ratings_file, "w") do |f|
        solar_ratings = [ SolarRating.find(55240) ]
        solar_ratings.each do |solar_rating|
          f << solar_rating.to_yaml
        end
      end
      
      #
      # Income tax brackets
      #
      
      income_tax_brackets_file = "#{RAILS_ROOT}/spec/fixtures/income_tax_brackets.yml"
      FileUtils.touch(income_tax_brackets_file)
      
      File.open(income_tax_brackets_file, "w") do |f|
        { "Married" => 100000.0 }.each do |status, income|
          federal_tax_brackets = [ FederalIncomeTaxBracket.find_by_filing_status_for_income(status, income) ]
          federal_tax_brackets.each do |federal_tax_bracket|
            f << federal_tax_bracket.to_yaml
          end
        
          state_tax_brackets = [ StateIncomeTaxBracket.find_by_state_and_filing_status_for_income("CA", status, income) ]
          state_tax_brackets.each do |state_tax_bracket|
            f << state_tax_bracket.to_yaml
          end
        end
      end
      
      #
      # Non-utility incentives
      #
      
      incentives_file = "#{RAILS_ROOT}/spec/fixtures/incentives.yml"
      FileUtils.touch(incentives_file)
      
      File.open(incentives_file, "w") do |f|
        federal_incentives = Incentive.find_federal_incentives
        federal_incentives.each do |i|
          f << i.to_yaml
        end
        
        state_incentives = Incentive.find_state_incentives_for("CA")
        state_incentives.each do |i|
          f << i.to_yaml
        end
        
        [ "Pacifica" ].each do |city|
          city_incentives = Incentive.find_city_incentives_for(city, "CA")
          city_incentives.each do |i|
            f << i.to_yaml
          end
        end
      end
      
      #
      # Utilities, tariffs, etc
      #
      
      
      utilities_file = "#{RAILS_ROOT}/spec/fixtures/utilities.yml"
      FileUtils.touch(utilities_file)
      
      tariffs_file = "#{RAILS_ROOT}/spec/fixtures/tariffs.yml"
      FileUtils.touch(tariffs_file)
      
      tiers_file = "#{RAILS_ROOT}/spec/fixtures/tiers.yml"
      FileUtils.touch(tiers_file)
      
      first = true
      utilities = { "Pacific Gas & Electric Co" => "Basic Territory X" }
      utilities.each do |utility_name, region|
        mode = first ? "w" : "a"
        
        utility = Utility.find_by_name(utility_name)
        
        File.open(utilities_file, mode) do |f|
          f << utility.to_yaml
        end
      
        tariff = utility.tariff_for(region)
        unless tariff.blank?
          File.open(tariffs_file, mode) do |f|
            f << tariff.to_yaml
          end
          
          File.open(tiers_file, mode) do |f|
            f << tariff.minimum_tier.to_yaml unless tariff.minimum_tier.blank?
            
            tariff.fixed_tiers.each do |tier|
              f << tier.to_yaml
            end
            
            tariff.variable_tiers.each do |tier|
              f << tier.to_yaml
            end
          end
        end
        
        File.open(incentives_file, "a") do |f|
          utility.incentives.each do |incentive|
            f << incentive.to_yaml
          end
        end
        
        first = false
      end
      
      puts "Done!"
    end
  end
end