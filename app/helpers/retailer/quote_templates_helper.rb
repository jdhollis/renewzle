module Retailer::QuoteTemplatesHelper
  def qt_module_fields_for(quote_template)
    render(:partial => 'retailer/quote_templates/modules', :locals => { :quote_template => quote_template, :modules => PhotovoltaicModule.find_all_by_manufacturer(quote_template.photovoltaic_module_manufacturer) }) if quote_template.photovoltaic_module_id
  end
  
  def qt_inverter_fields_for(quote_template)
    render(:partial => 'retailer/quote_templates/inverters', :locals => { :quote_template => quote_template, :inverters => PhotovoltaicInverter.find_all_by_manufacturer(quote_template.photovoltaic_inverter_manufacturer) }) if quote_template.photovoltaic_inverter_id
  end
end
