require File.dirname(__FILE__) + '/../../spec_helper'

describe Retailer::QuotesHelper do
  include Retailer::QuotesHelper

  describe "#module_fields_for" do
    it "should render modules partial"do
      @quote = stub_model(Quote)
      @quote.stub!(:photovoltaic_module_id).and_return(100)
      @modules = stub('modules')
      PhotovoltaicModule.should_receive(:find_all_by_manufacturer).and_return(@modules)
      self.should_receive(:render).with(:partial => 'retailer/quotes/modules', :locals => { :quote => @quote, :modules => @modules })
      module_fields_for(@quote)
    end
  end

  describe "#inverter_fields_for" do
    it "should render inverters partial"do
      @quote = stub_model(Quote)
      @quote.stub!(:photovoltaic_inverter_id).and_return(100)
      @inverters = stub('inverters')
      PhotovoltaicInverter.should_receive(:find_all_by_manufacturer).and_return(@inverters)
      self.should_receive(:render).with(:partial => 'retailer/quotes/inverters', :locals => { :quote => @quote, :inverters => @inverters })
      inverter_fields_for(@quote)
    end
  end  
end
