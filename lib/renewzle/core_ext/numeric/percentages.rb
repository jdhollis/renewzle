module Renewzle
  module CoreExtensions
    module Numeric
      module Percentages
        def percent
          self / 100.to_f
        end
      end
    end
  end
end
