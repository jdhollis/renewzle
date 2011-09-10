module ProfilesHelper
  def next_step_submit
    render(:partial => 'profiles/learn/next_step_submit')
  end
  
  def view_my_results_submit
    render(:partial => 'profiles/learn/view_my_results_submit')
  end

  def get_started_continue_or_review_quotes
    unless @profile.rfq?
      if @profile.getting_started?
        render(:partial => "profiles/learn/get_started_link")
      else
        render(:partial => "profiles/learn/continue")
      end
    else
      render(:partial => "profiles/learn/review_quotes")
    end
  end
  
  def call_to_action_get_started_continue_or_review_quotes
    unless @profile.rfq?
      if @profile.getting_started?
        render(:partial => "content/get_started_link")
      else
        render(:partial => "profiles/learn/continue")
      end
    else
      render(:partial => "profiles/learn/review_quotes")
    end
  end
  
  def get_started_utility
    if @profile.at_or_beyond_utility_stage?
      render(:partial => "profiles/learn/get_started_utility", :locals => { :profile => @profile })
    end
  end
  
  def get_started_region
    if !@profile.single_tariff? && @profile.at_or_beyond_region_stage?
      render(:partial => "profiles/learn/get_started_region", :locals => { :profile => @profile })
    end
  end
  
  def region_map
    if @profile.has_region_map?
      @template.content_tag('p', @template.image_tag("maps/#{@profile.utility.region_map}", :alt => "Region map for #{@profile.utility.name}"), :id => 'region_map')
    end
  end
  
  def get_started_usage
    if @profile.getting_started_with_usage?
      render(:partial => "profiles/learn/get_started_usage", :locals => { :profile => @profile })
    end
  end
  
  def view_my_results_button
    tag('input', :type => 'image', :src => image_path('customer/btn_view_my_results.gif'), :alt => 'View My Results', :class => 'button')
  end
  
  def sidebar
    unless @profile.rfq?
      render(:partial => "profiles/explore/sidebar", :locals => { :profile => @profile })
    else
      render(:partial => "profiles/explore/static_sidebar", :locals => { :profile => @profile })
    end
  end
  
  def next_required_field(profile_form)
    if @profile.postal_code.blank?
      render(:partial => "profiles/explore/whats_next_postal_code", :locals => { :profile_form => profile_form })
    elsif @profile.utility.blank?
      render(:partial => "profiles/explore/whats_next_utility", :locals => { :profile_form => profile_form })
    elsif !@profile.has_tariff?
      render(:partial => "profiles/explore/whats_next_region", :locals => { :profile_form => profile_form })
    elsif @profile.customer_has_not_reported_any_electricity_usage?
      render(:partial => "profiles/explore/whats_next_usage", :locals => { :profile_form => profile_form })
    end
  end
  
  def provider_fields(profile_form)
    unless @profile.utility.blank? && !@profile.has_tariff?
      render(:partial => "profiles/explore/provider_fields", :locals => { :profile_form => profile_form, :profile => @profile })
    end
  end
  
  def quote_request_link
    user = (!@user.blank? && @user.masquerading_as?(Customer)) ? @user.mask : @user
    if user && user.kind_of?(Customer) && user.verifying_email?
      render(:partial => "profiles/explore/verify_email")
    elsif @profile.ready_for_quotes?
      render(:partial => "profiles/explore/quote_request_link", :locals => { :profile => @profile })
    end
  end
  
  def solar_overview
    render_explore_view("solar_overview")
  end
  
  def solar_overview_cost_offset_chart
    unless @profile.postal_code.blank?
      unless @profile.utility.blank?
        if @profile.has_tariff?
          unless @profile.customer_has_not_reported_any_electricity_usage?
            render(:partial => "profiles/solar_overview_cost_offset_chart")
          end
        end
      end
    end
  end
  
  def system_output_and_electric_use
    render_explore_view("system_output_and_electric_use")
  end
  
  def financial_overview
    render_explore_view("financial_overview")
  end
  
  def environmental_overview
    render_explore_view("environmental_overview")
  end
  
  def with_and_without_solar
    prior_twelve_months = @profile.prior_twelve_months
    usage_without_solar_by_month = @profile.usage_without_solar_by_month
    usage_with_solar_by_month = @profile.usage_with_solar_by_month
    bill_without_solar_by_month = @profile.bill_without_solar_by_month
    bill_with_solar_by_month = @profile.bill_with_solar_by_month
    
    render(:partial => "profiles/explore/with_and_without_solar", :locals => { :profile => @profile, :prior_twelve_months => prior_twelve_months, :usage_without_solar_by_month => usage_without_solar_by_month, :usage_with_solar_by_month => usage_with_solar_by_month, :bill_without_solar_by_month => bill_without_solar_by_month, :bill_with_solar_by_month => bill_with_solar_by_month })
  end
  
  def quote_listing
    unless @profile.purchased_as_lead?
      unless @profile.waiting_for_quotes?
        render(:partial => "content/shop/quotes", :locals => { :quotes => @profile.quotes })
      else
        render(:partial => "content/shop/waiting_for_quotes")
      end
    else
      render(:partial => "content/shop/accepted_quote", :locals => { :quote => @profile.accepted_quote })
    end
  end
  
  def quotes_data
    returning(Hash.new) do |listing|
      quotes = @profile.quotes
      quotes.each do |p|
        [ :received, :first_year_savings, :lifetime_savings, :average_dollar_cost_per_cec_watt, :average_dollar_cost_per_nameplate_watt, :nameplate_rating, :cec_rating, :module_type, :number_of_modules, :inverter_type, :number_of_inverters, :system_price, :installation_available?, :installation_estimate, :will_accept_rebate_assignment?, :cash_outlay, :total_kw_installed, :installer_proximity_to_customer ].each do |m|
          value = p.send(m)
          listing.has_key?(m) ? listing[m] << value : listing[m] = [ value ]
        end
        
        listing.has_key?(:accept) ? listing[:accept] << p : listing[:accept] = [ p ]
      end
    end
  end
  
  def purchasing_partner_contact_information
    if @profile.purchased_as_lead?
      render(:partial => "content/shop/purchasing_partner_contact_information", :locals => { :partner => @profile.purchasing_partner })
    end
  end
  
  def dom_class_for(quote)
    classes = []
    classes << @template.dom_class(quote)
    
    if accepted_quote = @profile.accepted_quote
      if accepted_quote == quote
        classes << "accepted"
      else
        classes << "rejected"
      end
    end
    
    classes.join(" ")
  end
  
  def non_auto_submitting_utility_select_for(profile_form, attribs = {})
    utilities = @profile.find_nearest_utilities
    unless utilities.blank?
      profile_form.labelled_collection_select(:utility_id, utilities, :id, :name, attribs.merge({ :label => "Utility", :error_label => "Utility", :include_blank => "Please select your utility&hellip;" }))
    end
  end
  
  def non_auto_submitting_region_select_for(profile_form, attribs = {})
    tariffs = @profile.tariffs
    unless tariffs.blank?
      if tariffs.size > 1
        profile_form.labelled_collection_select(:region, tariffs, :region, :region, attribs.merge({ :label => "Utility region", :include_blank => "Please select your utility region&hellip;" }))
      end
    end
  end
  
  def ajax_utility_select_for(profile_form, form_id)
    utilities = @profile.find_nearest_utilities
    unless utilities.blank?
      profile_form.labelled_collection_select(:utility_id, utilities, :id, :name, { :label => "Utility", :include_blank => "Please select your utility&hellip;"}, :onchange => "submitForm('#{form_id}');")
    end
  end
  
  def utility_select_for(profile_form, form_id = "edit_profile_form")
    utilities = @profile.find_nearest_utilities
    unless utilities.blank?
      profile_form.labelled_collection_select(:utility_id, utilities, :id, :name, { :label => "Utility", :include_blank => "Please select your utility&hellip;" }, :onchange => "$('#{form_id}').submit();")
    end
  end
  
  def region_select_for(profile_form)
    tariffs = @profile.tariffs
    unless tariffs.blank?
      if tariffs.size > 1
        profile_form.labelled_collection_select(:region, tariffs, :region, :region, { :label => "Utility region", :include_blank => "Please select your utility region&hellip;" }, :onchange => "$('edit_profile_form').submit();")
      end
    end
  end
  
  def average_monthly_cost_before_graph_width
    @template.number_to_percentage([ (@profile.average_monthly_cost_before / (@profile.average_monthly_cost_before + @profile.average_monthly_cost_after) * 100), 1 ].max, :precision => 0)
  end
  
  def average_monthly_cost_after_graph_width
    @template.number_to_percentage([ (@profile.average_monthly_cost_after / (@profile.average_monthly_cost_before + @profile.average_monthly_cost_after) * 100), 1 ].max, :precision => 0)
  end
  
  def average_monthly_co2_emissions_before_graph_width
    @template.number_to_percentage([ (@profile.average_monthly_co2_emissions_before / (@profile.average_monthly_co2_emissions_before + @profile.average_monthly_co2_emissions_after) * 100), 1 ].max, :precision => 0)
  end
  
  def average_monthly_co2_emissions_after_graph_width
    @template.number_to_percentage([ (@profile.average_monthly_co2_emissions_after / (@profile.average_monthly_co2_emissions_before + @profile.average_monthly_co2_emissions_after) * 100), 1 ].max, :precision => 0)
  end

private
  
  def render_explore_view(view)
    unless @profile.postal_code.blank?
      unless @profile.utility.blank?
        if @profile.has_tariff?
          unless @profile.customer_has_not_reported_any_electricity_usage?
            render(:partial => "profiles/explore/#{view}", :locals => { :profile => @profile })
          else
            render(:partial => "profiles/explore/enter_usage")
          end
        else
          render(:partial => "profiles/explore/select_region")
        end
      else
        render(:partial => "profiles/explore/select_utility")
      end
    else
      render(:partial => "profiles/explore/enter_postal_code")
    end
  end
end
