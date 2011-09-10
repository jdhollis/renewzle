class ProfileNotifier < ActionMailer::Base
  include ApplicationHelper

  def rfq_confirmation_to(customer)
    content_type("text/html")
    recipients(customer.email)
    from("Renewzle Support <support@renewzle.com>")
    headers['Reply-To'] = 'support@renewzle.com'
    subject("[Renewzle] Request for quotes submitted")
    body(:quote_url => shop_url(:host => server_name))
  end
  
  def rfq_notification_to_partner_for(profile, partner)
    content_type("text/html")
    from("Renewzle Support <support@renewzle.com>")
    recipients(partner.email)
    from("Renewzle Support <support@renewzle.com>")
    headers['Reply-To'] = 'support@renewzle.com'
    subject("[Renewzle] A customer wants a solar Quote from your company")
    body(:dashboard_url => retailer_dashboard_url(:host => server_name), :profile => profile)
  end
end
