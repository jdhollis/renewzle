class CompanyBackgrounderNotifier < ActionMailer::Base
  include ApplicationHelper
  
  def on_create_notification(backgrounder)
    content_type("text/html")
    recipients('brad@renewzle.com')
    from("Renewzle Support <support@renewzle.com>")
    headers['Reply-To'] = 'support@renewzle.com'
    subject("[Renewzle] Company Backgrounder uploaded")
    body(:backgrounder => backgrounder)
  end
  
  def on_approve_notification(backgrounder)
    content_type("text/html")
    recipients(backgrounder.partner.email)
    from("Renewzle Support <support@renewzle.com>")
    headers['Reply-To'] = 'support@renewzle.com'
    subject("[Renewzle] Company Backgrounder approved")
    body(:backgrounder => backgrounder)
  end
  
  def on_reject_notification(backgrounder)
    content_type("text/html")
    recipients(backgrounder.partner.email)
    from("Renewzle Support <support@renewzle.com>")
    headers['Reply-To'] = 'support@renewzle.com'
    subject("[Renewzle] Company Backgrounder rejected")
    body(:backgrounder => backgrounder)
  end

end
