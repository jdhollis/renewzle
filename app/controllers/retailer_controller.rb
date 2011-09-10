class RetailerController < ApplicationController
	layout 'partner'

	before_filter :validate_login_credentials_if_any
	before_filter :setup_masquerade_assigns
	before_filter :verify_user_is_partner
	before_filter :set_partner_from_user
	before_filter :verify_partner_is_approved

private

	def verify_user_is_partner
		verify_user_is(Partner)
	end
  
  def set_partner_from_user
    @partner = @user.masquerading_as?(Partner) ? @user.mask : @user
  end
  
	def verify_partner_is_approved
		if @partner.waiting_approval
			destination_url = request.env['REQUEST_URI']
			session[:destination_url] = destination_url
			flash[:notice] = "You must complete the Partner approval process before continuing on to #{destination_url}."
			redirect_to(retailer_dashboard_url)
		end
	end
end
