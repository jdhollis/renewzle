module Renewzle
  module CoreExtensions
    module Numeric
      module Energy
        def watts
          self
        end
        alias :watt :watts
        alias :watt_hour :watt
        alias :watt_hours :watts
      
        def kilowatts
          self * 1000.watts
        end
        alias :kilowatt :kilowatts
        alias :kilowatt_hour :kilowatt
        alias :kilowatt_hours :kilowatts
        alias :kw :kilowatts
        alias :kwh :kilowatts
      end
    end
  end
end
