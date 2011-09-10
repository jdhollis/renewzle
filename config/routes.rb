ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'content', :requirements => { :method => :get } do |content|    
    content.how_solar_systems_work 'learn/how_solar_systems_work', :action => 'how_solar_systems_work'
    content.solar_power_costs_savings 'learn/solar_power_costs_savings', :action => 'solar_power_costs_savings'
    content.solar_and_the_environment 'learn/solar_and_the_environment', :action => 'solar_and_the_environment'
    content.rebates_and_incentives 'learn/rebates_and_incentives', :action => 'rebates_and_incentives'
    content.learn 'start', :action => 'get_started'
    
    content.cost_offset_chart_data 'explore/cost_offset_chart_data', :action => 'cost_offset_chart_data'
    content.print_profile 'explore/print', :action => 'print_profile'
    content.profile_financial_overview 'explore/financial', :action => 'financial_overview'
    content.annual_cost_chart_data 'explore/annual_cost_chart_data', :action => 'annual_cost_chart_data'
    content.cumulative_annual_savings_chart_data 'explore/cumulative_annual_savings_chart_data', :action => 'cumulative_annual_savings_chart_data'
    content.profile_environmental_overview 'explore/environmental', :action => 'environmental_overview'
    content.utility_source_mix_chart_data 'explore/utility_source_mix_data', :action => 'utility_source_mix_chart_data'
    content.profile_system_output_and_electric_use 'explore/system_output_and_electric_use', :action => 'system_output_and_electric_use'
    content.explore 'explore', :action => 'profile_overview'
    
    content.profile_rfq 'request_quotes', :action => 'request_quotes'
    content.rfq_confirmation 'rfq_confirmation', :action => 'request_quotes_confirmation'
    
    content.shop 'shop', :action => 'quotes'
    
    content.how_renewzle_works 'how_renewzle_works', :action => 'how_renewzle_works'
    
    content.about 'about', :action => 'about'
    content.press 'press', :action => 'press'
    content.faq 'faq', :action => 'faq'
    content.tos 'tos', :action => 'tos'
    content.privacy_policy 'privacy_policy', :action => 'privacy_policy'
    
    content.links 'resources/external_solar_and_environmental_links', :action => 'links'
    
    content.ways_to_save_energy_around_the_home 'ways_to_save_energy_around_the_home', :action => 'ways_to_save_energy_around_the_home'
  end
  
  map.resource :profile
  
  map.with_options :controller => 'customers', :requirements => { :method => :get } do |customer|
    #customer.verify 'account/verify/:verification_code', :action => 'verify'
    customer.account 'account', :action => 'edit'
    customer.cancel_account 'account/cancel', :action => 'cancel'
  end
  map.resource :customer
  
  map.with_options :controller => 'leads', :requirements => { :method => :get } do |leads|
    leads.accept_quote 'quotes/:id/accept', :action => 'new'
  end
  map.resources :leads
 
 	map.with_options :controller => 'companies', :requirements => { :method => :get } do |company|
		company.company_list 'companies', :action => 'show'
	end	
  map.resources :companies
  
  map.with_options :controller => 'sessions', :requirements => { :method => :get } do |session|
    session.login 'login', :action => 'new'
    session.logout 'logout', :action => 'destroy'
    session.forgot_password 'password/forgot', :action => 'forgot_password'
	  session.reset_password 'password/reset/:key', :action => 'reset_password'
  end
  map.resource :session
  
  map.with_options :controller => 'partners', :requirements => { :method => :get } do |partner|
    partner.partner_signup 'retailer/signup', :action => 'new'
  end
  map.resource :partner
  
  map.namespace :admin do |admin|
    admin.dashboard 'dashboard', :controller => 'admins', :action => 'index'
    admin.resources :companies

		admin.with_options :controller => 'discounts', :requirements => { :method => :get } do |admin_discounts|
			admin_discounts.discount_new 'discounts/:type/new', :action => 'new'
		end 
    admin.resources :discounts

    admin.resources :incentives
    admin.resources :leads
    admin.resources :profiles
    admin.resources :quotes
    admin.resources :users
    
    map.with_options :controller => 'admin/masquerades' do |admin_masquerades|
      admin_masquerades.masquerade_panel 'admin/masquerade', :action => 'index', :requirements => { :method => :get }
      admin_masquerades.start_masquerading 'admin/masquerade/start', :action => 'create', :requirements => { :method => :post }
      admin_masquerades.stop_masquerading 'admin/masquerade/stop', :action => 'destroy', :requirements => { :method => :get }
    end
    
    map.with_options :controller => 'admin/backgrounders', :requirements => { :method => :get } do |admin_backgrounders|
      admin_backgrounders.approve_admin_backgrounder 'admin/backgrounders/approve/:id', :action => 'approve'
      admin_backgrounders.reject_admin_backgrounder 'admin/backgrounders/reject/:id', :action => 'reject'
    end
    
    map.with_options :controller => 'admin/backgrounders', :requirements => { :method => :post } do |admin_backgrounders|
      admin_backgrounders.confirm_reject_admin_backgrounder 'admin/backgrounders/confirm_reject/:id', :action => 'confirm_reject'
    end
    
    admin.resources :backgrounders
  end
  
  map.with_options :controller => 'retailer_content', :requirements => { :method => :get } do |retailer_content|
    retailer_content.retailer_faq 'retailer/faq', :action => 'faq'
    retailer_content.retailer_help 'retailer/help', :action => 'help'
  end
  
  map.namespace :retailer do |retailer|
  	retailer.dashboard 'dashboard', :controller => 'profiles', :action => 'index'
        retailer.counties 'counties', :controller => 'counties', :action => 'index'
  	retailer.resources :companies
    
		retailer.with_options :controller => 'partners', :requirements => { :method => :get } do |retailer_partners|
			retailer_partners.account 'account', :action => 'edit'
      retailer_partners.cancel_account 'account/cancel', :action => 'destroy'
		end 
  	retailer.resources :partners

		retailer.with_options :controller => 'quotes', :requirements => { :method => :get } do |retailer_quotes|                                        
			retailer_quotes.new_quote_for_profile 'profiles/:profile_id/quotes/new', :action => 'new'
		end 
  	retailer.resources :quotes
		
		retailer.with_options :controller => 'leads', :requirements => { :method => :get } do |retailer_leads|                                        
			retailer_leads.purchase_lead 'leads/:id/purchase', :action => 'edit'
		end 
  	retailer.resources :leads

  	retailer.with_options :controller => 'solutions', :requirements => { :method => :get } do |retailer_solutions|
			retailer_solutions.lead_disposition 'lead/:id/disposition', :action => 'new'
		end
  	retailer.resources :solutions
  	
  	retailer.resources :quote_templates
  	
  	retailer.with_options :controller => 'content', :requirements => { :method => :get } do |retailer_content|
  	  retailer_content.about 'about', :action => 'about'
  	  retailer_content.tos 'tos', :action => 'tos'
  	  retailer_content.privacy_policy 'privacy_policy', :action => 'privacy_policy'
	  end
	  
	  retailer.resources :backgrounders
  end

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

  map.connect '*path', :controller => 'content', :action => 'default' # catch-all
end
