class CustomerController < ApplicationController
  layout 'customer'

  before_filter :validate_login_credentials_if_any
  before_filter :setup_masquerade_assigns

private
  
  def recall_remembered_profile_if_any
    if !@user.blank? && (@user.kind_of?(Customer) || @user.masquerading_as?(Customer))
      @profile = @user.profile
      cookies.delete('remembered_profile_id')
    else
      remembered_profile_id = request.cookies['remembered_profile_id']
      unless remembered_profile_id.blank?
        unless @profile = Profile.find_unowned(remembered_profile_id)
          cookies.delete('remembered_profile_id')
        end
      end
    end
  end
  
  def redirect_to_new_profile_url_if_no_remembered_profile
    redirect_to(new_profile_url) if @profile.blank?
  end
  
  def verify_user_is_customer
    verify_user_is(Customer)
  end
  
  def setup_profile_overview_assigns
    @location = 'explore'
    @tab = 'profile_overview'
    session[:current_tab_url] = explore_url
    @view_title = 'Your Solar Overview'
  end
  
  def setup_financial_overview_assigns
    @location = 'explore'
    @tab = 'financial_overview'
    session[:current_tab_url] = profile_financial_overview_url
    @view_title = 'Financial Overview'
  end
  
  def setup_environmental_overview_assigns
    @location = 'explore'
    @tab = 'environmental_overview'
    session[:current_tab_url] = profile_environmental_overview_url
    @view_title = 'Environmental Overview'
  end
  
  def setup_system_output_and_electric_use_assigns
    @location = 'explore'
    @tab = 'system_output_and_electric_use'
    session[:current_tab_url] = profile_system_output_and_electric_use_url
    @view_title = 'System Output & Electric Use'
  end
  
  def setup_request_quotes_assigns
    @location = 'explore'
    @view_title = 'Request Quotes'
  end
end
