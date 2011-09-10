xml.chart(:caption => "#{@profile.utility.name} Energy Source Mix", :numberSuffix => "%", :showBorder => "0", :borderThickness => "0", :bgColor => "ffffff", :bgAlpha => "100", :use3DLighting => "0") do
  @utility_source_mix.each do |source, percentage|
    xml.set(:label => source, :value => percentage, :toolText => "#{source}, #{percentage}%")
  end
end