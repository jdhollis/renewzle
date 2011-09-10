class QuoteNotifier < ActionMailer::Base
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper

  def quote_confirmation_to_partner_for(quote)
    content_type("text/html")
    recipients(quote.partner.email)
    from("Renewzle Support <support@renewzle.com>")
    headers['Reply-To'] = 'support@renewzle.com'
    subject("[Renewzle] Your Quote has been received")
    body(:dashboard_url => retailer_dashboard_url(:host => server_name), :quote => quote)
  end
  
  def quote_notification_to_customer_for(quote)
    content_type("text/html")
    recipients(quote.customer.email)
    from("Renewzle Support <support@renewzle.com>")
    headers['Reply-To'] = 'support@renewzle.com'
    subject("[Renewzle] You've received a new quote from a Renewzle solar installer")
    
    profile_nameplate_rating = number_with_delimiter(number_with_precision(quote.profile.nameplate_rating, 1))
    quote_nameplate_rating = number_with_delimiter(number_with_precision(quote.nameplate_rating, 1))
    system_price = number_to_accounting(quote.system_price, :precision => 0)
    cost_per_watt = number_to_accounting(quote.average_dollar_cost_per_nameplate_watt, :precision => 2)
    
    body(:shop_url => shop_url(:host => server_name), :quote => quote, :profile_nameplate_rating => profile_nameplate_rating, :quote_nameplate_rating => quote_nameplate_rating, :system_price => system_price, :cost_per_watt => cost_per_watt)
  end
  
  def quote_withdrawal_confirmation_to_partner_for(quote)
    content_type("text/html")
    recipients(quote.partner.email)
    from("Renewzle Support <support@renewzle.com>")
    headers['Reply-To'] = 'support@renewzle.com'
    subject("[Renewzle] Quote withdrawn")
    body(:dashboard_url => retailer_dashboard_url(:host => server_name))
  end
end
