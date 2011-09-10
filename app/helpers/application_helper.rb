module ApplicationHelper
  def server_name
    (ENV['SERVER_DOMAIN']) ? ENV['SERVER_DOMAIN'] : 'www.renewzle.com'
  end

  def message_from(f)
    returning(String.new) do |messages_markup|
      [ :warning, :notice, :message ].each do |k|
        unless f[k].blank?
          messages_markup << content_tag('p', f.delete(k), :class => k.to_s)
          break
        end
      end
    end
  end
  
	def meta_description
		tag('meta', :name => 'description', :content => h(@meta_description)) unless @meta_description.blank?
	end 
	
	def meta_keywords
		tag('meta', :name => 'keywords', :content => h(@meta_keywords)) unless @meta_keywords.blank?
	end 
	
	def google_webmaster_tools
    render(:partial => 'layouts/google_webmaster_tools')
	end
	
	def view_title
		@view_title.blank? ? 'Renewzle.com' : "#{@view_title} &mdash; Renewzle.com"
	end 

	def mint
		render(:partial => 'layouts/mint') if in_production?
	end

	def google_analytics
		render(:partial => 'layouts/google_analytics') if in_production?
	end

	def dom_id_from(string)
		string.blank? ? '' : " id=\"#{string}\""
	end

	def in_production?
		ENV['RAILS_ENV'] == 'production'
	end
	
	def masquerade_protocol
	  in_production? ? 'https' : 'http'
	end
  
  def masquerade_panel
    render(:partial => 'admin/masquerades/masquerade_panel') if @user.kind_of?(Administrator)
  end
  
  def masquerade_as
    unless @masquerade_as_customers.blank? && @masquerade_as_partners.blank?
      render(:partial => 'admin/masquerades/masquerade_as')
    else
      render(:partial => 'admin/masquerades/no_one_to_masquerade_as')
    end
  end
  
  def masquerade_status
    if @user.masquerading?
      render(:partial => 'admin/masquerades/masquerading_as')
    else
      render(:partial => 'admin/masquerades/masquerading_off')
    end
  end
  
  def return_to_masquerade
    if @user.masquerading?
      content_tag('p', link_to("Return to <strong>masquerading as #{@user.mask.kind_of?(Profile) ? "a #{number_with_delimiter(number_with_precision(@user.mask.nameplate_rating, 1))} DC kW system in #{@user.mask.city}" : @user.mask.full_name}</strong>", home_url))
    end
  end
  
	def home_url
    url = learn_url
    
    if @user.blank?
      unless @profile.blank? || @profile.getting_started?
        url = explore_url
      end
    else
      user = @user.masquerading? ? @user.mask : @user
      
      case user
      when Customer
        if profile = user.profile
          unless profile.getting_started?
            unless profile.rfq?
              url = explore_url
            else
              url = shop_url
            end
          end
        end
      when Partner
        url = retailer_dashboard_url
      when Administrator
        url = admin_dashboard_url
      end
    end
    
    url
	end

  def next_button
    tag('input', :type => 'image', :src => image_path('btn_next.png'), :alt => 'Next', :class => "button")
  end
	
	def page_javascript
		javascript_tag(@page_javascript.uniq.join('\n')) unless @page_javascript.blank?
	end 
  
	def separator
		content_tag('span', '|', :class => 'separator')
	end

  def loading_span_of_size(size, options = {})
    if options.has_key?(:for)
      unless options[:for].kind_of?(String)
        span_id = dom_id(options[:for])
      else
        span_id = "#{options[:for]}_loading"
      end
    else
      span_id = nil
    end
    
    content_tag('span', image_tag('loading.gif', :alt => 'loading indicator', :height => size, :width => size), :id => span_id, :class => 'loading', :style => 'display:none')
  end

  def my_account_link
    returning('') do |account_link|
      unless @user.nil? || (@user.kind_of?(Administrator) && !@user.masquerading?)
        user = @user.masquerading? ? @user.mask : @user
        
        case user
        when Customer
          url = account_url
        when Partner
          url = retailer_account_url
        end
        
        li_contents = link_to('My Account', url, :title => 'Edit my account information')
        li_contents << separator
        
        account_link << content_tag('li', li_contents, { :class => 'my_account' })
      end
    end
  end

  def login_logout_link
    returning('') do |login_logout_link|
      unless @user.blank?
        url = @user.masquerading? ? stop_masquerading_url : logout_url
        li_contents = link_to('Logout', url)
        li_attribs = {}
      else
        li_contents = link_to('Login', login_url)
        li_attribs = { :id => 'login_link' }
      end
      
      login_logout_link << content_tag('li', li_contents, li_attribs)
    end
  end

	def number_to_accounting(number, options = {})                                                                                                             
		options   = options.stringify_keys                                                                                                                       
		precision = options['precision'] || 2                                                                                                                    
		unit      = options['unit'] || '$'                                                                                                                       
		separator = precision > 0 ? options['separator'] || '.' : ''                                                                                             
		delimiter = options['delimiter'] || ','                                                                                                                  
	
		begin
		  number = 0.0 if number.to_i == 0                                                                                                                                          
			if number < 0                                                                                                                                  
				parts = number_with_precision(-number, precision).split('.')                                                                                         
				content_tag('span', unit + '(' + number_with_delimiter(parts[0], delimiter) + separator + parts[1].to_s + ')', :class => 'negative')
			else
				parts = number_with_precision(number, precision).split('.')                                                                                          
				unit + number_with_delimiter(parts[0], delimiter) + separator + parts[1].to_s                                                                        
			end                                                                                                                                                    
		rescue                                                                                                                                                   
			number                                                                                                                                                 
		end                                                                                                                                                      
	end 
	
	def number_with_delimiter_and_parens(number, suffix = '', delimiter = ',', separator = '.')
    begin
      if number.to_f < 0
        parts = (-number.to_f).to_s.split('.')
        parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
        content_tag('span', ('(' + parts.join(separator) + ')' + " #{suffix}").chop, :class => 'negative')
      else
        parts = number.to_s.split('.')
        parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
        (parts.join(separator) + " #{suffix}").chop
      end
    end
  end

  def labelled_form_for(object, options = {}, &block)
    options = options.merge(:onsubmit => 'preventFormResubmission(this);') unless options.has_key?(:onsubmit)
    form_for(object, options.merge(:builder => Renewzle::LabellingFormBuilder), &block)
  end
  
  def labelled_fields_for(object_name, object, options = {}, &block)
    fields_for(object_name, object, options.merge(:builder => Renewzle::LabellingFormBuilder), &block)
  end
  
  def labelled_remote_form_for(object, options = {}, &block)
    options = options.merge(:html => { :onsubmit => 'preventFormResubmission(this)' }) unless options.has_key?(:html)
    remote_form_for(object, options.merge(:builder => Renewzle::LabellingFormBuilder), &block)
  end

  def initial_visit?
    @user.blank? && @profile.blank?
  end

  def in_learn?
    @location == 'learn'
  end

  def in_explore?
    @location == 'explore'
  end

  def in_shop?
    @location == 'shop'
  end

  def learn_link
    returning(String.new) do |link|
      attributes = { :id => 'learn_chevron', :class => 'learn chevron' }
      if initial_visit? || !in_learn?
        attributes[:onmouseover] = "CustomerNavi.replaceNaviDetailsWith('#{render(:partial => 'layouts/customer/learn_details')}');"
        attributes[:onmouseout] = "CustomerNavi.replaceNaviDetailsWith('#{details_for_current_customer_view}');"
      end
			# raise attributes.inspect
      
      link << content_tag('li', link_to("#{content_tag('strong', 'Learn')} the basics", learn_url), attributes)
    end
  end

  def explore_link
    returning(String.new) do |link|
      profile = (@user.blank? || (!@user.kind_of?(Customer) && !@user.masquerading_as?(Customer))) ? @profile: @user.profile
      
      attributes = { :id => 'explore_chevron', :class => 'explore chevron' }
      if !in_explore?
        attributes[:onmouseover] = "CustomerNavi.replaceNaviDetailsWith('#{render(:partial => 'layouts/customer/explore_details', :locals => { :profile => profile })}');"
        attributes[:onmouseout] = "CustomerNavi.replaceNaviDetailsWith('#{details_for_current_customer_view}');"
      end
      
      link_attributes = {}
      if profile.blank? || profile.getting_started?
        link_attributes[:class] = 'inactive'
        url = ''
      else
        url = explore_url
      end
      
      contents = link_to("#{content_tag('strong', 'Explore')} your options", url, link_attributes)
      
      link << content_tag('li', contents, attributes)
    end
  end

  def shop_link
    returning(String.new) do |link|
      attributes = { :id => 'shop_chevron', :class => 'shop chevron' }
      if !in_shop?
        attributes[:onmouseover] = "CustomerNavi.replaceNaviDetailsWith('#{render(:partial => 'layouts/customer/shop_details')}');"
        attributes[:onmouseout] = "CustomerNavi.replaceNaviDetailsWith('#{details_for_current_customer_view}');"
      end
      
      link_attributes = {}
      if ((@user.blank? || (!@user.kind_of?(Customer) && !@user.masquerading_as?(Customer))) || @user.profile.blank?) || !@user.profile.rfq?
        link_attributes[:class] = 'inactive'
        url = ''
      else
        url = shop_url
      end
      
      contents = link_to("#{content_tag('strong', 'Shop')} for a system", url, link_attributes)
      
      link << content_tag('li', contents, attributes)
    end
  end

  def details_for_current_customer_view
    if initial_visit?
      render(:partial => 'layouts/customer/welcome')
    else
      if in_learn?
        render(:partial => 'layouts/customer/learn_details')
      elsif in_explore?
        profile = (@user.blank? || (!@user.kind_of?(Customer) && !@user.masquerading_as?(Customer))) ? @profile: @user.profile
        render(:partial => 'layouts/customer/explore_details', :locals => { :profile => profile })
      elsif in_shop?
        render(:partial => 'layouts/customer/shop_details')
      end
    end
  end

  def customer_local_navi
    if in_learn?
      render(:partial => 'layouts/customer/learn_navi')
    elsif in_explore?
      render(:partial => 'layouts/customer/explore_navi')
    end
  end

  def submit_button(contents, tag_attributes = {})
    attributes = tag_attributes.merge(:type => 'submit')
    content_tag('button', contents, attributes)
  end

  def possible_filing_statuses
    [ 'Single', 'Married', 'Married filing separately', 'Head of household' ]
  end

  def possible_lead_dispositions
    [ 'Sold', 'Decided not to buy', 'Not ready to purchase at this time', 'Could not contact' ]
  end
  
  def states_by_abbreviation
    { 'AL' => 'Alabama',
      'AK' => 'Alaska', 
      'AZ' => 'Arizona',
      'AR' => 'Arkansas',
      'CA' => 'California',
      'CO' => 'Colorado',
      'CT' => 'Connecticut',
  		'DE' => 'Delaware',
  		'DC' => 'District of Columbia',
  		'FL' => 'Florida',
  		'GA' => 'Georgia',
  		'HI' => 'Hawaii',
  		'ID' => 'Idaho',
  		'IL' => 'Illinois',
  		'IN' => 'Indiana',
  		'IA' => 'Iowa',
  		'KS' => 'Kansas',
  		'KY' => 'Kentucky',
  		'LA' => 'Louisiana',
  		'ME' => 'Maine',
  		'MD' => 'Maryland',
  		'MA' => 'Massachusetts',
  		'MI' => 'Michigan',
  		'MN' => 'Minnesota',
  		'MS' => 'Mississippi',
  		'MO' => 'Missouri',
  		'MT' => 'Montana',
  		'NE' => 'Nebraska',
  		'NV' => 'Nevada',
  		'NH' => 'New Hampshire',
  		'NJ' => 'New Jersey',
  		'NM' => 'New Mexico',
  		'NY' => 'New York',
  		'NC' => 'North Carolina',
  		'ND' => 'North Dakota',
  		'OH' => 'Ohio',
  		'OK' => 'Oklahoma',
  		'OR' => 'Oregon',
  		'PA' => 'Pennsylvania',
  		'RI' => 'Rhode Island',
  		'SC' => 'South Carolina',
  		'SD' => 'South Dakota',
  		'TN' => 'Tennessee',
  		'TX' => 'Texas',
  		'UT' => 'Utah',
  		'VT' => 'Vermont',
  		'VA' => 'Virginia',
  		'WA' => 'Washington',
  		'WV' => 'West Virginia',
  		'WI' => 'Wisconsin',
  		'WY' => 'Wyoming' }
  end
  
  def full_state_name_for(abbreviation)
    states_by_abbreviation[abbreviation]
  end
end
