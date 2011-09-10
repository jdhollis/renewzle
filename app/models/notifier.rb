class Notifier < ActionMailer::Base	
  include ApplicationHelper

  def forgot_password(user)
    content_type('text/html')
    from('support@renewzle.com')
    recipients(user.email)
    headers['Reply-To'] = 'support@renewzle.com'
    sent_on(Time.now)
    subject('[Renewzle] Reset your password')
    body(:user => user, :reset_password_url => reset_password_url(:host => server_name, :key => user.password_reset_key))
  end
end
