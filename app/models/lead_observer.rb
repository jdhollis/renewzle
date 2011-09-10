class LeadObserver < ActiveRecord::Observer
  def after_create(lead)
    LeadNotifier.deliver_quote_acceptance_confirmation_to_customer_for(lead)
    LeadNotifier.deliver_lead_notification_to_partner_for(lead)
  end
end
