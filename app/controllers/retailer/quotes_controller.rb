class Retailer::QuotesController < RetailerController
  ssl_required :show, :new, :create

	def index
		@location = 'quotes'
		@view_title = 'My Quotes'
	end	

	def show
		@quote = @partner.quotes.find(params[:id])
		@location = 'quotes'
		@view_title = "Quote for '#{@quote.customer.full_name}'"
	end

	def new
	  setup_quote_templates
    setup_manufacturers
    setup_company_backgrounders
		@profile = Profile.find(params[:profile_id])
    @quote = Quote.new
    @quote.profile = @profile
		@location = 'quotes'
		@view_title = 'Make a Quote'
	end

	def create
	  setup_manufacturers
	  setup_company_backgrounders
	  quote_params = params['quote'].blank? ? { 'partner' => @partner } : params['quote'].merge('partner' => @partner)
		@quote = Quote.new(quote_params)
		@save_as_template = params['save_as_template']
		if request.xhr?
			render(:update) do |page|
				case params['update']
			  when 'template'
			    @profile = Profile.find(params['profile_id'])
		      @quote.profile = @profile
		      
          unless params['quote_template'].blank?
            @quote_template = @partner.find_company_quote_template(params['quote_template'])
            @quote_template.apply_to(@quote)
          end
          
          page.hide("#{params['input']}_loading")
          page.replace_html('quote', :partial => 'retailer/quotes/quote', :locals => { :quote => @quote })
          page.replace_html('quote_form', :partial => 'retailer/quotes/form', :locals => { :quote => @quote, :module_manufacturers => @module_manufacturers, :inverter_manufacturers => @inverter_manufacturers, :company_backgrounders => @company_backgrounders })
          page.visual_effect(:scroll_to, 'quote_form')
				when 'quote'
					page.hide("#{params['input']}_loading")
					page.replace_html('quote', :partial => 'retailer/quotes/quote', :locals => { :quote => @quote })
				when 'modules'
					page.hide('photovoltaic_module_manufacturer_loading')
					page.replace_html('photovoltaic_module_fields', :partial => 'retailer/quotes/modules', :locals => { :quote => @quote, :modules => PhotovoltaicModule.find_all_by_manufacturer(params[:quote][:photovoltaic_module_manufacturer]) })
				when 'inverters'
					page.hide('photovoltaic_inverter_manufacturer_loading')
					page.replace_html('photovoltaic_inverter_fields', :partial => 'retailer/quotes/inverters', :locals => { :quote => @quote, :inverters => PhotovoltaicInverter.find_all_by_manufacturer(params[:quote][:photovoltaic_inverter_manufacturer]) })
				end
			end
		else
      if @quote.company_backgrounder && (@quote.company_backgrounder.waiting_approval? || !@quote.company_backgrounder.approved?)
        @quote.company_backgrounder_id = nil
      end
			@quote.save!
			@quote.save_as_template! if @save_as_template
			flash[:notice] = 'Quote submitted.'
			redirect_to(retailer_dashboard_url)
		end
	rescue ActiveRecord::RecordInvalid
	  setup_quote_templates
    setup_manufacturers
    setup_company_backgrounders
		@profile = @quote.profile
		render(:action => 'new')
	end

	def destroy
		@quote = @partner.quotes.find(params[:id])
		@quote.destroy

		respond_to do |wants|
			wants.html do
				flash[:notice] = 'Your quote has been withdrawn.'
				redirect_to(retailer_dashboard_url)
			end
			wants.js do 
				render(:update) do |page|
					page.visual_effect(:fade, dom_id(@quote))
					page.replace_html('messages', content_tag('p', 'Your quote has been withdrawn.', :class => 'notice'))
					page.visual_effect(:highlight, 'messages')
				end
			end
		end
	end

private

  def setup_quote_templates
    @quote_templates = @partner.company.quote_templates
  end

  def setup_manufacturers
    @module_manufacturers = PhotovoltaicModule.find_manufacturers
    @inverter_manufacturers = PhotovoltaicInverter.find_manufacturers
  end
  
  def setup_company_backgrounders
    @company_backgrounders = @partner.company.company_backgrounders.available
  end
end
