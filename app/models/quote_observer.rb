class QuoteObserver < ActiveRecord::Observer
  def after_create(quote)
    QuoteNotifier.deliver_quote_confirmation_to_partner_for(quote)
    QuoteNotifier.deliver_quote_notification_to_customer_for(quote)
  end
  
#  def after_destroy(quote)
#    QuoteNotifier.deliver_quote_withdrawal_confirmation_to_partner_for(quote)
#  end
end
