class PhotovoltaicInverter < ActiveRecord::Base
  def self.find_manufacturers
    self.find(:all, :select => "DISTINCT(manufacturer) AS manufacturer")
  end

  def model_and_description
    "#{model_number} #{description}"
  end
  
  def manufacturer_and_description
    "<strong>#{manufacturer}</strong> #{description}"
  end
end
