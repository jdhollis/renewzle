require 'fastercsv'

class Admin::ExportController < AdminController
  ssl_required :utilties, :tariffs
  
	def utilities
	  utilities = Utility.find(:all)
	  stream_csv do |csv|
      csv << [ 'utility_id', 'name', 'state', 'rate', 'jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec', 'summer_starting_month', 'summer_ending_month', 'nox_rate', 'so2_rate', 'co2_rate', 'mercury_rate', 'percent_coal', 'percent_oil', 'percent_gas', 'percent_nuclear', 'percent_hydro', 'percent_biomass', 'percent_wind', 'percent_solar', 'percent_geothermal', 'percent_other', 'percent_unknown' ]
      utilities.each { |u| csv << [ u.utility_id, u.name, u.state, u.rate, u.jan, u.feb, u.mar, u.apr, u.may, u.jun, u.jul, u.aug, u.sep, u.oct, u.nov, u.dec, u.summer_starting_month, u.summer_ending_month, u.nox_rate, u.so2_rate, u.co2_rate, u.mercury_rate, u.percent_coal, u.percent_oil, u.percent_gas, u.percent_nuclear, u.percent_hydro, u.percent_biomass, u.percent_wind, u.percent_solar, u.percent_geothermal, u.percent_other, u.percent_unknown ] }
    end
	end
	
	def tariffs
	  tariffs = Tariff.find(:all)
	  stream_csv do |csv|
	    csv << [ 'utility_id', 'utility_name', 'state', 'description', 'region', 'season', 'type', 'min_usage', 'max_usage', 'rate' ]
	    tariffs.each do |tariff|
        initial = [ tariff.utility.utility_id, tariff.utility.name, tariff.utility.state, tariff.description, tariff.region ]
        [ :minimum_tier, :fixed_tiers, :variable_tiers, :tiered_fixed_tiers ].each do |tier_collection|
          unless tier_collection == :minimum_tier
            tiers = tariff.send(tier_collection)
          else
            minimum_tier = tariff.send(tier_collection)
            tiers = minimum_tier.blank? ? [ ] : [ minimum_tier ]
          end
          
          tiers.each do |tier|
            type = tier.class.to_s.gsub(/Tier$/, '')
            csv << initial + [ tier.season, type, tier.min_usage, tier.max_usage, tier.rate ]
          end
        end
      end
    end
	end

private

  def stream_csv
    filename = params[:action] + ".csv"    

    #this is required if you want this to work with IE        
    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma'] = 'public'
      headers["Content-type"] = "text/plain" 
      headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
      headers['Content-Disposition'] = "attachment; filename=\"#{filename}\"" 
      headers['Expires'] = "0" 
    else
      headers["Content-Type"] ||= 'text/csv'
      headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" 
    end

    render :text => Proc.new { |response, output|
      csv = FasterCSV.new(output, :row_sep => "\r\n") 
      yield csv
    }
  end
end
