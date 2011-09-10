# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
	include SslRequirement

  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  # protect_from_forgery :secret => 'd0a99fb14b2c11a074e106931af2cdee'
  protect_from_forgery :secret => '34275fa3d3a0f366adcc527d7ec8cae1', :only => [ :create, :update, :destroy ]

  filter_parameter_logging 'password', 'card_number', 'card_expiration_month', 'card_expiration_year', 'card_verification'

	before_filter :setup_page_javascript

private

	def setup_page_javascript
		@page_javascript = []
	end

  def setup_masquerade_assigns
    if @user.kind_of?(Administrator)
      @masquerade_as_profiles = Profile.find_all_by_customer_id(nil, :order => 'updated_at DESC', :limit => 30)
      @masquerade_as_profiles = @masquerade_as_profiles.collect { |p| p unless p.getting_started? }.compact
      @masquerade_as_customers = Customer.find(:all, :order => 'last_name ASC')
      @masquerade_as_partners = Partner.find(:all, :order => 'last_name ASC')
      @masquerade_as_partners = @masquerade_as_partners.sort { |a, b| a.company.name <=> b.company.name }
    end
  end
  
  def remember(profile)
    cookies['remembered_profile_id'] = { :value => profile.to_param, :expires => Time.now + 3.months }
  end

  def login(user)
    @login_token = user.login!
    cookies['login_token_value'] = { :value => @login_token.value, :expires => Time.now + 3.months }
  end

  def validate_login_credentials_if_any
    case request.format
    when Mime::RSS
      if user = authenticate_with_http_basic { |email, password| User.authenticate(email, password) }
        @user = user
      else
        request_http_basic_authentication
      end
    else
      login_token_value = request.cookies['login_token_value']
      unless login_token_value.blank?
        if @login_token = LoginToken.find_by_value(login_token_value)
          @user = @login_token.user
        end
      end
    end
  end

	def verify_user_is(kind)
	  if @user.nil? || (!@user.kind_of?(kind) && !@user.masquerading_as?(kind))
	    destination_url = request.env['REQUEST_URI']
	    session[:destination_url] = destination_url
	    flash[:notice] = "Please log in before we send you along to #{destination_url}."
		  redirect_to(login_url)
	  end
	end

  def default_url
    user = (!@user.blank? && @user.masquerading?) ? @user.mask : @user
    
    case user
    when Customer
      user.profile.rfq? ? shop_url : explore_url
    when Partner
      retailer_dashboard_url
    when Administrator
      admin_dashboard_url
    else
      (@profile.blank? || @profile.getting_started?) ? learn_url : explore_url
    end
  end
end
