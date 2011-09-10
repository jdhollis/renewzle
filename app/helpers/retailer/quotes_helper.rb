module Retailer::QuotesHelper
  def module_fields_for(quote)
    render(:partial => 'retailer/quotes/modules', :locals => { :quote => quote, :modules => PhotovoltaicModule.find_all_by_manufacturer(quote.photovoltaic_module_manufacturer) }) if quote.photovoltaic_module_id
  end
  
  def inverter_fields_for(quote)
    render(:partial => 'retailer/quotes/inverters', :locals => { :quote => quote, :inverters => PhotovoltaicInverter.find_all_by_manufacturer(quote.photovoltaic_inverter_manufacturer) }) if quote.photovoltaic_inverter_id
  end
end
