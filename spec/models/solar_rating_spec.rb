require File.dirname(__FILE__) + '/../spec_helper'

describe SolarRating do
  before(:each) do
    @solar_rating = SolarRating.new
  end
  
  it "should act_as_mappable" do
    @solar_rating.should respond_to(:lat)
    @solar_rating.should respond_to(:lng)
    @solar_rating.should respond_to(:distance)
    SolarRating.included_modules.should include(GeoKit::ActsAsMappable::InstanceMethods)
    SolarRating.included_modules.should include(GeoKit::Mappable)
  end
end