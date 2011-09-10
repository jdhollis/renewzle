maximum_cost = nil
minimum_cost = nil
@annual_cost_before_and_after.each do |year, before_after|
  yearly_maximum = before_after[:before] > before_after[:after] ? before_after[:before] : before_after[:after]
  yearly_minimum = before_after[:before] < before_after[:after] ? before_after[:before] : before_after[:after]
  
  unless maximum_cost.blank?
    maximum_cost = yearly_maximum > maximum_cost ? yearly_maximum : maximum_cost
  else
    maximum_cost = yearly_maximum
  end
  
  unless minimum_cost.blank?
    minimum_cost = yearly_minimum < minimum_cost ? yearly_minimum : minimum_cost
  else
    minimum_cost = yearly_minimum
  end
end

xml.chart(:caption => 'Annual Cost', :xAxisName => 'Year', :yAxisName => 'Annual cost', :showValues => '0', :decimals => '0', :numberPrefix => '$', :showAlternateHGridColor => '0', :divLineColor => 'cccccc', :showBorder => '0', :borderThickness => '0', :adjustDiv => '0', :yAxisMinValue => minimum_cost, :yAxisMaxValue => maximum_cost, :canvasBorderThickness => '1', :canvasBorderColor => 'cccccc', :bgColor => 'ffffff', :bgAlpha => '100') do
  xml.categories do
    @annual_cost_before_and_after.keys.sort.each do |year|
      show_label = year > 1 && year % 5 > 0 ? '0' : '1'
      xml.category(:label => year, :showLabel => show_label)
    end
  end
  
  xml.dataset(:seriesName => 'Before installation', :lineThickness => '1', :color => '6a4600') do
    @annual_cost_before_and_after.keys.sort.each do |year|
      cost = @annual_cost_before_and_after[year][:before]
      xml.set(:value => cost, :toolText => "#{number_to_currency(cost, :precision => 0)} at year #{year}")
    end
  end
  
  xml.dataset(:seriesName => 'After installation', :lineThickness => '1', :color => '00a021') do
    @annual_cost_before_and_after.keys.sort.each do |year|
      cost = @annual_cost_before_and_after[year][:after]
      xml.set(:value => cost, :toolText => "#{number_to_currency(cost, :precision => 0)} at year #{year}")
    end    
  end
end