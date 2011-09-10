namespace :log do
  desc "Creates the log directory with empty log files for each environment"
  task :create do
    FileUtils.mkdir("log")
    %w( development.log production.log test.log ).each do |log_file|
      f = File.open("log/#{log_file}", "w")
      f.close
    end
  end
end
