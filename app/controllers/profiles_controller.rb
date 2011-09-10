class ProfilesController < CustomerController
  before_filter :recall_remembered_profile_if_any, :except => :create
  before_filter :redirect_to_new_profile_url_if_no_remembered_profile, :only => :update
  
  def new
    @profile = Profile.new if @profile.blank?
    setup_new_assigns
  end
  
  def create
    additional_profile_params = { 'validate_postal_code' => true }
    
    unless @user.blank? || (!@user.kind_of?(Customer) && !@user.masquerading_as?(Customer))
      user = @user.masquerading_as?(Customer) ? @user.mask : @user
      additional_profile_params['customer'] = user
    end
    
    @profile = Profile.create!(params['profile'].merge(additional_profile_params))
    remember(@profile) unless @profile.is_owned?
    
    respond_to do |wants|
      wants.html do
        redirect_to(new_profile_url)
      end
      
      # In case user ends up on /profile/new at the postal_code stage for some reason...
      wants.js do
        render(:update) do |page|
          page.replace('postal_code', :partial => 'profiles/learn/get_started_postal_code', :locals => { :profile => @profile })
          page.insert_html(:bottom, 'get_started_fields', :partial => 'profiles/learn/get_started_utility', :locals => { :profile => @profile, :initially_hidden => true })
          page.visual_effect(:appear, 'utility', :duration => 0.2)
          
          page.delay(0.35) do
            page.visual_effect(:scroll_to, 'utility')
          end
        end
      end
    end
  rescue ActiveRecord::RecordInvalid
    flash[:non_california_postal_code] = true
    
    respond_to do |wants|
      wants.html do
        redirect_to(ways_to_save_energy_around_the_home_url)
      end
      
      # In case user ends up on /profile/new at the postal_code stage for some reason...
      wants.js do
        render(:update) do |page|
          page.redirect_to(ways_to_save_energy_around_the_home_url)
        end
      end
    end
  end
  
  def update
    @profile.update_from(params['profile'])
    remember(@profile) unless @profile.is_owned?
    
    if @profile.getting_started?
      if request.xhr?
        render(:update) do |page|
          previous_field = @profile.last_completed_getting_started_field
          page.replace(previous_field, :partial => "profiles/learn/get_started_#{previous_field}", :locals => { :profile => @profile })
          next_fields = @profile.next_getting_started_fields
          
          next_fields.each do |next_field|
            page.insert_html(:bottom, 'get_started_fields', :partial => "profiles/learn/get_started_#{next_field}", :locals => { :profile => @profile, :initially_hidden => true })
            page.visual_effect(:appear, next_field, :duration => 0.2)
            page.delay(0.35) do
              page.visual_effect(:scroll_to, next_field)
              page.call('Form.focusFirstElement', "edit_#{dom_id(@profile)}_usage") if next_field == 'usage'
            end
          end
        end
      else
        redirect_to(new_profile_url)
      end
    else
      if request.xhr?
        @profile.optimize_system_size!
        render(:update) do |page|
          page.redirect_to(explore_url)
        end
      else
        redirect_to(session[:current_tab_url] || explore_url)
      end
    end
  rescue ActiveRecord::RecordInvalid
    if @profile.getting_started?
      if request.xhr?
        render(:update) do |page|
          current_field = @profile.current_getting_started_field
          page.replace(current_field, :partial => "profiles/learn/get_started_#{current_field}", :locals => { :profile => @profile })
          page.visual_effect(:scroll_to, current_field)
        end
      else
        setup_new_assigns
        flash[:warning] = 'Please review and correct the errors below.'
      
        render(:action => 'new')
      end
    else
      flash[:warning] = 'Please review and correct the errors below.'
      render_current_explore_tab
    end
  end

private
  
  def render_current_explore_tab
    case session[:current_tab_url]
    when profile_financial_overview_url
      setup_financial_overview_assigns
      action = { :controller => 'content', :action => 'financial_overview' }
    when profile_environmental_overview_url
      setup_environmental_overview_assigns
      action = { :controller => 'content', :action => 'environmental_overview' }
    when profile_system_output_and_electric_use_url
      setup_system_output_and_electric_use_assigns
      action = { :controller => 'content', :action => 'system_output_and_electric_use' }
    else
      setup_profile_overview_assigns
      action = { :controller => 'content', :action => 'profile_overview' }
    end
    
    render(action)
  end
  
  def setup_new_assigns
    @location = 'learn'
    @tab = 'get_started'
    session[:current_tab_url] = new_profile_url
    @view_title = 'Get Started'
  end
end
