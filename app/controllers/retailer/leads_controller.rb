class Retailer::LeadsController < RetailerController
  ssl_required :show, :edit, :update

  rescue_from Renewzle::CreditCardInvalid, :with => :return_to_edit
  rescue_from Renewzle::PaymentAuthorizationFailed, :with => :return_to_edit
  rescue_from Renewzle::DiscountInvalid, :with => :return_to_edit

	def index
		@location = 'leads'
		@view_title = 'My Leads'

		@filter = params[:filter]
		case @filter
		when 'open'
			@leads = @partner.leads.paginate(:conditions => { :closed => false }, :per_page => 20, :page => params[:page])
		when 'closed'
			@leads = @partner.leads.paginate(:conditions => { :closed => true }, :per_page => 20, :page => params[:page])
		else
			@filter = 'all'
			@leads = @partner.leads.paginate(:per_page => 20, :page => params[:page])
		end
	end	

	def show
		@lead = @partner.leads.find(params[:id])
		@location = 'leads'
		@view_title = @lead.customer.full_name
	end

	def edit
		@location = 'leads'
		@view_title = "Purchase Lead"
		@lead = @partner.leads.find(params[:id])
    @profile = @lead.profile
    @lead.set_billing_information_from(@partner)
	end

	def update
		@lead = @partner.leads.find(params[:id])

		respond_to do |format|
			format.html do
				@lead.ip_address = request.env['REMOTE_HOST']
				@lead.attributes = params['lead']
				@lead.purchase!
				flash[:notice] = 'Thanks for purchasing a lead.'
				redirect_to(retailer_lead_url(@lead))
			end
			format.js do
				@lead.update_from(params[:lead])
				render(:update)  do |page|
					page.visual_effect(:highlight, dom_id(@lead))
					page.redirect_to(retailer_lead_disposition_url(@lead)) if @lead.closed?
				end
			end
		end
	rescue ActiveRecord::RecordInvalid
		render(:action => 'edit')
	end

private

  def return_to_edit(exception)
    flash[:warning] = exception.message
    #@lead.errors.add_to_base(exception.message)
    render(:action => 'edit')
  end
end
