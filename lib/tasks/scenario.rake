def load_fixtures_for_scenario(scenario)
  require 'active_record/fixtures'
  `cd #{RAILS_ROOT.gsub(' ', "\\ ")}; rake RAILS_ENV=#{RAILS_ENV} db:reset`
  ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
  Dir.glob(File.join(RAILS_ROOT, 'spec', 'fixtures', 'scenarios', scenario.to_s, '*.yml').gsub(' ', "\\ ")).each do |fixture_file|
    Fixtures.create_fixtures("spec/fixtures/scenarios/#{scenario.to_s}", File.basename(fixture_file, '.*'))
  end
end

# the password is 'test' for all user accounts
namespace :scenario do
  namespace :load do
    desc 'waiting_for_quotes — customer has create profile, registered, and submitted an RFQ. no quotes have yet been made by partners.'
    task :waiting_for_quotes => :environment do
      load_fixtures_for_scenario(:waiting_for_quotes)
      puts 'Done!'
    end

    desc 'evaluating_quotes — multiple partners have made quotes on the RFQ.'
    task :evaluating_quotes => :environment do
      load_fixtures_for_scenario(:evaluating_quotes)
      puts 'Done!'
    end

    desc 'waiting_for_partner — customer has accepted one of the quotes and is waiting for the partner to purchase the lead.'
    task :waiting_for_partner => :environment do
      load_fixtures_for_scenario(:waiting_for_partner)
      puts 'Done!'
    end

    desc 'lead_purchased — partner has purchased lead, providing customer with their contact information.'
    task :lead_purchased => :environment do
      load_fixtures_for_scenario(:lead_purchased)
      puts 'Done!'
    end
  end
end
