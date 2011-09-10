module Renewzle
  module Conversions
    def convert_string_to_positive_float(s)
      value = s.gsub(/[$,]/, '').to_f
      value.abs
    end
    
    def convert_percentage_string_to_positive_float(s)
      percentage = convert_string_to_positive_float(s)
      percentage.blank? ? nil : percentage.percent
    end
  end
end