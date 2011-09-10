class CustomerNotifier < ActionMailer::Base
  include ApplicationHelper

  def registration_confirmation_to(customer)
    content_type("text/html")
    recipients(customer.email)
    headers['Reply-To'] = 'support@renewzle.com'
    from("Renewzle Support <support@renewzle.com>")
    subject("[Renewzle] You have successfully registered!")
    body(:renewzle_url => url_for(:host => server_name, :controller => "content", :action => "default"), :explore_url => explore_url(:host => server_name), :shop_url => shop_url(:host => server_name))
  end

  def verification_to(customer)
    content_type("text/html")
    recipients(customer.email)
    headers['Reply-To'] = 'support@renewzle.com'
    from("Renewzle Support <support@renewzle.com>")
    subject("[Renewzle] Verify your account")
    body(:renewzle_url => url_for(:host => server_name, :controller => "content", :action => "default"), :verification_url => verify_url(customer.verification_code, :host => server_name))
  end
  
  def cancellation_confirmation_to(customer)
    content_type("text/html")
    recipients(customer.email)
    headers['Reply-To'] = 'support@renewzle.com'
    from("Renewzle Support <support@renewzle.com>")
    subject("[Renewzle] Account cancelled")
  end
end
