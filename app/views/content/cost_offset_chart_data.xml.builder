maximum_cost = @monthly_electric_cost_by_offset.values.max
minimum_cost = @monthly_electric_cost_by_offset.values.min
xml.chart(:caption => 'Monthly Cost (Electric Bill and Solar Loan Payment) by System Size', :xAxisName => 'Percent of Electric Use Offset by Solar', :yAxisName => 'Monthly cost', :showValues => '0', :decimals => '0', :numberPrefix => '$', :showLegend => '0', :showAlternateHGridColor => '0', :divLineColor => 'cccccc', :showBorder => '0', :borderThickness => '0', :adjustDiv => '0', :yAxisMinValue => minimum_cost, :yAxisMaxValue => maximum_cost, :canvasBorderThickness => '1', :canvasBorderColor => 'cccccc', :bgColor => 'ffffff', :bgAlpha => '100') do  
  xml.categories do
    @monthly_electric_cost_by_offset.keys.sort.each do |offset|
      show_label = offset > 0 && offset % 10 > 0 ? '0' : '1'
      xml.category(:label => "#{offset}%", :showLabel => show_label)
    end
  end
  
  xml.dataset(:seriesName => 'Monthly Cost', :lineThickness => '1', :color => '00a021') do
    @monthly_electric_cost_by_offset.keys.sort.each do |offset|
      cost = @monthly_electric_cost_by_offset[offset]
      xml.set(:value => cost, :toolText => "#{number_to_currency(cost, :precision => 2)} at #{offset}% offset")
    end
  end
end