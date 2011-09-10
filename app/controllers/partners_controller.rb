class PartnersController < ApplicationController
  layout 'pre_signup_partner'
  
  before_filter :validate_login_credentials_if_any
  before_filter :setup_masquerade_assigns
  
	ssl_required :new, :create

  def new
    respond_to do |wants|
      wants.html do
        set_new_meta_variables
      end
      
      wants.js do
        @company = Company.find(params['id'])
        @company.default_to_cec_fields
        @partner = Partner.new

        render(:update) do |page|
          page.replace_html('registration', :partial => 'partners/registration', :locals => { :partner => @partner, :company => @company })
				  page.delay(0.35) do
					  page.visual_effect(:scroll_to, 'registration')
				  end
        end
      end
    end
  end
  
  def create
    Company.transaction do
      @company = Company.find(params['company']['id'])
      @partner = @company.register(params['partner'])
      @company.update_from(params['company'])
    end
    
    login(@partner)
    flash[:notice] = "Thanks for signing up! We'll be contacting you shortly."
    redirect_to(retailer_dashboard_url)
  rescue ActiveRecord::RecordInvalid
    set_new_meta_variables
    flash[:warning] = 'Please review and correct the validation errors below before resubmitting.'
    flash[:company_name] = params['company_name']
    render(:action => 'new')
  end
  
private

  def set_new_meta_variables
    @location = 'partner_signup'
    @view_title = 'Solar Energy Installers & Professionals – Register to Find Sales Leads at Renewzle'
    @meta_description = 'Solar installers and retailers, get matched with highly qualified sales leads for residential solar panel sales. Homeowners interested in solar energy installations are waiting for you.'
    @meta_keywords = 'solar panel sales leads, solar power leads, solar installer leads, residential solar energy, solar rfp, solar lead generation, solar power installation jobs'
  end
end
