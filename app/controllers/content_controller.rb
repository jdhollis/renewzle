class ContentController < CustomerController
  layout 'customer', :except => [ :print_profile, :cost_offset_chart_data, :annual_cost_chart_data, :cumulative_annual_savings_chart_data, :utility_source_mix_chart_data ]
  
  before_filter :redirect_to_shop_if_customer_has_submitted_rfq, :only => :request_quotes
  before_filter :redirect_to_explore_if_customer_has_not_submitted_rfq, :only => :request_quotes_confirmation
  before_filter :redirect_to_shop_if_customer_has_already_submitted_rfq, :only => :request_quotes_confirmation
  before_filter :verify_user_is_customer, :only => [ :request_quotes_confirmation, :quotes ]
  before_filter :redirect_to_explore_if_customer_has_not_verified_email, :only => [ :request_quotes_confirmation, :quotes ]
  before_filter :recall_remembered_profile_if_any
  before_filter :redirect_to_new_profile_url_if_no_remembered_profile, :only => [ :profile_overview, :financial_overview, :environmental_overview, :system_output_and_electric_use, :print_profile, :request_quotes, :request_quotes_confirmation, :cost_offset_chart_data, :annual_cost_chart_data, :cumulative_annual_savings_chart_data, :utility_source_mix_chart_data ]

  def default
    redirect_to(default_url)
  end
  
  def get_started
    @profile = Profile.new if @profile.blank?

    @location = 'learn'
    @tab = 'get_started'
    session[:current_tab_url] = learn_url
    @view_title = 'Residential Solar Energy Made Easy'
    @meta_description = 'Do you want to install solar panels for your home? Renewzle answers these questions: What is the right solar power system size? How much does solar save in energy costs? How can you get the best price from the best solar system retailers and installers  With information and a calculator for residential solar energy systems, Renewzle makes solar power easy.'
    @meta_keywords = 'solar energy, solar power, solar panels, residential solar energy systems, residential solar power, solar installer, solar power retailer, photovoltaics, photovoltaic panels, solar pv panels, solar system cost, solar system size, solar system comparison tool, solar financial analysis'

    if @profile.new_record?
      render(:template => 'content/get_started', :layout => false) and return
    else
      render(:template => 'profiles/continue') and return
    end
  end

  def how_solar_systems_work
    @profile = Profile.new if @profile.blank?

    @location = 'learn'
    @tab = 'how_solar_systems_work'
    session[:current_tab_url] = how_solar_systems_work_url
    @view_title = 'How Solar Systems Work'
    @meta_description = 'Curious how solar panels would work in your house? Learn about all the components of a home solar system and how they function together, including information on solar modules and panels, solar inverters, electrical panels, utility meters and the utility grid.'
    @meta_keywords = 'how solar energy works, how solar panels work, solar modules, solar inverters, photovoltaic cells, photovoltaic panels, solar grid'
  end

  def solar_power_costs_savings
    @profile = Profile.new if @profile.blank?

    @location = 'learn'
    @tab = 'solar_power_costs_savings'
    session[:current_tab_url] = solar_power_costs_savings_url
    @view_title = 'Solar Power Costs & Savings'
    @meta_description = 'Are solar panels really cost effective? Renewzle identifies the elements of the cost of solar power and helps you estimate the approximate cost to install solar panels in your home. What are your potential cost savings from solar energy?'
    @meta_keywords = 'solar enery cost, solar panel cost, cost to install solar panels, solar power cost, is solar power cost efficient, how much do solar panels cost, solar cost savings, solar panel price, solar power financial factors'
  end

  def solar_and_the_environment
    @profile = Profile.new if @profile.blank?

    @location = 'learn'
    @tab = 'solar_and_the_environment'
    session[:current_tab_url] = solar_and_the_environment_url
    @view_title = 'Solar Energy & the Environment'
    @meta_description = 'How does switching to solar power help the environment? Get information here on how solar energy compares to fossil fuels in terms of toxic pollutants, emissions and consumption of non-renewable resources.'
    @meta_keywords = 'facts about solar energy, how clean is solar energy, solar energy vs fossil fuels, reducing carbon dioxide, nitrogen oxide, sulphur dioxide, particulates, reducing air pollutants, conserve fossil fuels, solar power and environment'
  end

  def rebates_and_incentives
    @profile = Profile.new if @profile.blank?

    @location = 'learn'
    @tab = 'rebates_and_incentives'
    session[:current_tab_url] = rebates_and_incentives_url
    @view_title = 'Solar Rebates & Financial Incentives'
    @meta_description = 'Find information on federal, state and utility rebates and incentives that apply when you install a residential solar power system. Incentives can come in the form of tax credits or rebates from utilities, and can often cover a substantial portion of the total cost of installing a solar system for your home.'
    @meta_keywords = 'solar tax credit, solar panel tax credit, solar energy tax credit, federal solar tax credit, solar rebate, solar electricity tax refund, solar energy tax incentive, solar energy rebate, solar panel rebate, federal solar incentives, photovoltaic incentives, solar photovoltaic grant'
  end
  
  def profile_overview
    setup_profile_overview_assigns
  end
  
  def cost_offset_chart_data
    respond_to do |format|
      format.xml { @monthly_electric_cost_by_offset = @profile.monthly_electric_cost_by_offset }
    end
  end
  
  def financial_overview
    setup_financial_overview_assigns
  end
  
  def annual_cost_chart_data
    respond_to do |format|
      format.xml { @annual_cost_before_and_after = @profile.annual_cost_before_and_after }
    end
  end
  
  def cumulative_annual_savings_chart_data
    respond_to do |format|
      format.xml { @cumulative_annual_savings = @profile.cumulative_annual_savings }
    end
  end
  
  def environmental_overview
    setup_environmental_overview_assigns
  end
  
  def utility_source_mix_chart_data
    respond_to do |format|
      format.xml { @utility_source_mix = @profile.utility_source_mix }
    end
  end
  
  def system_output_and_electric_use
    setup_system_output_and_electric_use_assigns
  end
  
  def print_profile
    @view_title = 'Solar Financial Analysis Summary'
  end
  
  def request_quotes
    if @user.blank? || (!@user.kind_of?(Customer) && !@user.masquerading_as?(Customer))
      @customer = Customer.new
      @customer.set_address_from(@profile)
    else
      @customer = @user.masquerading_as?(Customer) ? @user.mask : @user
    end
    
    setup_request_quotes_assigns
  end
  
  def request_quotes_confirmation
    @location = 'shop'
    @view_title = "Congratulations! You're now shopping for solar!"
  end
  
  def quotes
    @location = 'shop'
    
    if @profile.quotes.blank?
      @view_title = "Congratulations! You’re now shopping for solar!"
    else
      @view_title =  'Your System Quotes are Listed Below!'
    end
  end
  
  def about
    @view_title = 'About Renewzle: Solar Tool Connecting Homeowners & Installers'
    @meta_description = 'Brought to you by Renewzle Inc., Renewzle is a green web tool designed to help consumers better understand the financial and environmental effects of solar energy and to help homeowners shop for a solar system that fits their needs. Renewzle is a solar calculator that helps you find the best installer in your area.'
    @meta_keywords = 'renewzle, what is renewzle, greenweb, renewzle solar power tool, green options solar tool, greenweb tool'
    render(:template => 'shared/about')
  end
  
  def press
    @view_title = 'Renewzle in the News'
    render(:template => 'shared/press')
  end
  
  def how_renewzle_works
    @view_title = 'How Renewzle Works: Using the Solar Calculator & Requesting Quotes from Solar Installers'
  end
  
  def faq
    @view_title = 'Frequently Asked Questions about Renewzle & Installing a Solar System' 
    @meta_description = 'Have questions about Renewzle and installing a solar power system? Find answers here. Information on solar system sizing, solar energy costs and financial analysis, proposals and quotes from installers, and how to work with Renewzle.'
    @meta_keywords = 'renewzle frequently asked questions, renewzle faq, solar power faq, solar system size, solar financial analysis, solar panel rfp'
    render(:template => 'shared/faq')
  end
  
  def privacy_policy
    @view_title = 'Privacy Policy'
    render(:template => 'shared/privacy_policy')
  end
  
  def tos
    @view_title = 'Terms of Service'
    render(:template => 'shared/tos')
  end
  
  def links
    @view_title = 'Other Solar and Environmental Resources'
    render(:template => 'shared/links')
  end
  
  def ways_to_save_energy_around_the_home
    @view_title = 'Top 5 Areas to Save Energy Around the Home'
    @location = 'ways_to_save_energy_around_the_home'
    @profile = Profile.new if @profile.blank?
  end
  
private
  
  def redirect_to_shop_if_customer_has_submitted_rfq
    unless @user.blank?
      redirect_to(shop_url) if (@user.kind_of?(Customer) || @user.masquerading_as?(Customer)) && @user.profile.rfq?
    end
  end
  
  def redirect_to_explore_if_customer_has_not_submitted_rfq
    redirect_to(explore_url) if @user.blank? || !@user.profile.rfq?
  end
  
  def redirect_to_shop_if_customer_has_already_submitted_rfq
    redirect_to(shop_url) unless flash[:just_submitted_rfq]
  end
  
  def redirect_to_explore_if_customer_has_not_verified_email
    #if @user.verifying_email?
    #  flash[:notice] = 'Please verify your email address before proceeding.'
    #  redirect_to(explore_url)
    #end
    true
  end
end
