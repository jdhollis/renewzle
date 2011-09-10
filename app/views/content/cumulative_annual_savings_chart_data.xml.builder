maximum_savings = @cumulative_annual_savings.values.max
minimum_savings = @cumulative_annual_savings.values.min
xml.chart(:caption => 'Cumulative Annual Savings', :xAxisName => 'Year', :yAxisName => 'Cumulative savings / cost', :showValues => '0', :decimals => '0', :numberPrefix => '$', :showLegend => '0', :showAlternateHGridColor => '0', :divLineColor => 'cccccc', :showBorder => '0', :borderThickness => '0', :adjustDiv => '0', :yAxisMinValue => minimum_savings, :yAxisMaxValue => maximum_savings, :canvasBorderThickness => '1', :canvasBorderColor => 'cccccc', :bgColor => 'ffffff', :bgAlpha => '100', :numDivLines => 2) do  
  xml.categories do
    @cumulative_annual_savings.keys.sort.each do |year|
      show_label = year % 5 > 0 ? '0' : '1'
      xml.category(:label => year, :showLabel => show_label)
    end
  end
  
  xml.dataset(:seriesName => 'Cumulative annual savings', :lineThickness => '1', :color => '00a021') do
    @cumulative_annual_savings.keys.sort.each do |year|
      savings = @cumulative_annual_savings[year]
      xml.set(:value => savings, :toolText => "#{number_to_currency(savings, :precision => 0)} for year #{year}")
    end
  end
end