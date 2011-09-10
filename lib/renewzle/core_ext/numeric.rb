Dir[File.dirname(__FILE__) + '/numeric/*.rb'].each { |file| require(file) }

class Numeric #:nodoc:
  include Renewzle::CoreExtensions::Numeric::Energy
  include Renewzle::CoreExtensions::Numeric::Percentages
end
