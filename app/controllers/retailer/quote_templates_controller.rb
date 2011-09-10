class Retailer::QuoteTemplatesController < RetailerController
  ssl_required :index, :new, :create, :edit, :update, :destroy

	def index
		@location = 'quote_templates'
		@view_title = 'Manage Quote Templates'
		@quote_templates = @partner.quote_templates
	end
	
	def new
	  @location = 'quote_templates'
		@view_title = 'Make a Quote Template'
		@quote_template = QuoteTemplate.new
		setup_manufacturers
		setup_company_backgrounders
	end
	
  def create
		@quote_template = QuoteTemplate.new(params['quote_template'].merge('partner' => @partner))
		if request.xhr?
			render(:update) do |page|
				case params['update']
				when 'quote_template'
					page.hide("#{params['input']}_loading")
					page.replace_html('quote_template', :partial => 'retailer/quote_templates/quote_template', :locals => { :quote_template => @quote_template })
				when 'modules'
					page.hide('photovoltaic_module_manufacturer_loading')
					page.replace_html('photovoltaic_module_fields', :partial => 'retailer/quote_templates/modules', :locals => { :quote_template => @quote_template, :modules => PhotovoltaicModule.find_all_by_manufacturer(params['quote_template']['photovoltaic_module_manufacturer']) })
				when 'inverters'
					page.hide('photovoltaic_inverter_manufacturer_loading')
					page.replace_html('photovoltaic_inverter_fields', :partial => 'retailer/quote_templates/inverters', :locals => { :quote_template => @quote_template, :inverters => PhotovoltaicInverter.find_all_by_manufacturer(params['quote_template']['photovoltaic_inverter_manufacturer']) })
				end
			end
		else
			@quote_template.save!
			flash[:notice] = 'Quote template created.'
			redirect_to(retailer_quote_templates_url)
		end
	rescue ActiveRecord::RecordInvalid
    setup_manufacturers
    setup_company_backgrounders
		render(:action => 'new')
	end
	
	def edit
	  @quote_template = @partner.quote_templates.find(params['id'])
	  @quote_template.set_manufacturers
	  @location = 'quote_templates'
		@view_title = "Edit #{@quote_template.description}"
		setup_manufacturers
		setup_company_backgrounders
	rescue ActiveRecord::RecordNotFound
	  render(:file => 'public/404.html', :status => 404)
	end
	
	def update
    @quote_template = @partner.quote_templates.find(params['id'])
		@quote_template.attributes = params['quote_template']
		if request.xhr?
			render(:update) do |page|
				case params['update']
				when 'quote_template'
					page.hide("#{params['input']}_loading")
					page.replace_html('quote_template', :partial => 'retailer/quote_templates/quote_template', :locals => { :quote_template => @quote_template })
				when 'modules'
					page.hide('photovoltaic_module_manufacturer_loading')
					page.replace_html('photovoltaic_module_fields', :partial => 'retailer/quote_templates/modules', :locals => { :quote_template => @quote_template, :modules => PhotovoltaicModule.find_all_by_manufacturer(params['quote_template']['photovoltaic_module_manufacturer']) })
				when 'inverters'
					page.hide('photovoltaic_inverter_manufacturer_loading')
					page.replace_html('photovoltaic_inverter_fields', :partial => 'retailer/quote_templates/inverters', :locals => { :quote_template => @quote_template, :inverters => PhotovoltaicInverter.find_all_by_manufacturer(params['quote_template']['photovoltaic_inverter_manufacturer']) })
				end
			end
		else
			@quote_template.save!
			flash[:notice] = 'Quote template updated.'
			redirect_to(retailer_quote_templates_url)
		end
	rescue ActiveRecord::RecordNotFound
	  render(:file => 'public/404.html', :status => 404)
	rescue ActiveRecord::RecordInvalid
    setup_manufacturers
    setup_company_backgrounders
		render(:action => 'edit')
	end
	
	def destroy
		@quote_template = @partner.quote_templates.find(params['id'])
		@quote_template.destroy

		respond_to do |wants|
			wants.html do
				flash[:notice] = 'Your quote template has been destroyed.'
				redirect_to(retailer_quote_templates_url)
			end
			wants.js do 
				render(:update) do |page|
					page.visual_effect(:fade, dom_id(@quote_template))
					page.replace_html('messages', content_tag('p', 'Your quote template has been destroyed.', :class => 'notice'))
					page.visual_effect(:highlight, 'messages')
				end
			end
		end
	rescue ActiveRecord::RecordNotFound
	  render(:file => 'public/404.html', :status => 404)
	end
	
private

  def setup_manufacturers
    @module_manufacturers = PhotovoltaicModule.find_manufacturers
    @inverter_manufacturers = PhotovoltaicInverter.find_manufacturers
  end
  
  def setup_company_backgrounders
    @company_backgrounders = @partner.available_company_backgrounders
  end
end
