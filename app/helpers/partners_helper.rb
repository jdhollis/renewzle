module PartnersHelper
  def company_search_results_for(companies)
    if companies.blank?
      render(:partial => 'companies/no_companies_found')
    else
      render(:partial => 'companies/company_search_results', :locals => { :companies => companies, :search_term => '' })
    end
  end

  def registration_for(partner, company)
    render(:partial => 'partners/registration', :locals => { :partner => partner, :company => company }) unless partner.blank?
  end

  def purchased_leads_link
    content_tag('li', link_to('My Leads', retailer_leads_url) + separator, :class => 'leads') if @partner && @partner.has_purchased_leads?
  end

  def edit_company_link
    content_tag('li', link_to('My Company', edit_retailer_company_url(@partner.company)) + separator, :class => 'company') if @partner && @partner.can_update_company_profile?
  end
  
  def manage_company_backgrounders_link
    content_tag('li', link_to('Company Backgrounders', retailer_backgrounders_url) + separator, :class => 'backgrounders') if @partner && @partner.can_manage_company_backgrounders?
  end
  
  def manage_counties_link
    content_tag('li', link_to('Service Area', retailer_counties_url), :class => 'counties') if @partner && @partner.can_manage_counties?
  end

  def administrator_title_for(partner)                                                                                         
    content_tag('span', 'Administrator', :class => 'title') if partner.company_administrator                                   
  end                                                                                                                          

  def make_quote_link_for(rfq, quotes)                                                                                         
    if @partner.can_submit_quotes                                                                                          
      label = quotes.blank? ? 'Make a quote' : 'Make another'                                                                  
      link_to(label, retailer_new_quote_for_profile_url(rfq), :class => "create")                                                       
    end                                                                                                                        
  end      

  def permission_inputs_for(partner, partner_form)
    unless partner.company_administrator
      render(:partial => 'retailer/partners/permission_inputs', :locals => { :partner => partner, :partner_form => partner_form })
    end
  end
  
  def datetime_format(datetime)
    datetime.mday.to_s + datetime.strftime(" %B %Y at ") + datetime.hour.to_s + datetime.strftime(".%M %p").downcase
  end
end
