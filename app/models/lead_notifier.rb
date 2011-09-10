class LeadNotifier < ActionMailer::Base
  include ApplicationHelper

  def quote_acceptance_confirmation_to_customer_for(lead)
    content_type("text/html")
    recipients(lead.customer.email)
    from("Renewzle Support <support@renewzle.com>")
    headers['Reply-To'] = 'support@renewzle.com'
    subject("[Renewzle] You have accepted a solar installer's quote Quote")
    body(:shop_url => shop_url(:host => server_name), :lead => lead)
  end
  
  def lead_notification_to_partner_for(lead)
    content_type("text/html")
    recipients(lead.partner.email)
    from("Renewzle Support <support@renewzle.com>")
    headers['Reply-To'] = 'support@renewzle.com'
    subject("[Renewzle] Your Quote has been accepted")
    body(:dashboard_url => retailer_dashboard_url(:host => server_name), :lead => lead)
  end
  
  def purchase_confirmation_to_partner_for(lead)
    content_type("text/html")
    recipients(lead.partner.email)
    from("Renewzle Support <support@renewzle.com>")
    headers['Reply-To'] = 'support@renewzle.com'
    subject("[Renewzle] Lead purchase confirmation")
    body(:dashboard_url => retailer_dashboard_url(:host => server_name))
  end
  
  def lead_followup_for(lead)
    content_type("text/html")
    recipients(lead.partner.email)
    headers['Reply-To'] = 'support@renewzle.com'
    from("Renewzle Support <support@renewzle.com>")
    subject("[Renewzle] Has #{lead.profile.customer.full_name} signed a contract?")
    body(:lead_disposition_url => retailer_lead_disposition_url(lead, :host => server_name))
  end
end
