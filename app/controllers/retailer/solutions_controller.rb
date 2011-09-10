class Retailer::SolutionsController < RetailerController
  ssl_required :new, :create

	def new
		@lead = @partner.leads.find(params[:id])
		@location = 'solutions'
		@view_title = 'Lead Disposition'
	end

	def create
		@solution = Solution.new(params[:solution])
		@solution.save!
		flash[:notice] = 'Lead disposition saved.'
		redirect_to(retailer_leads_url)
	rescue ActiveRecord::RecordInvalid
		render(:action => 'new')
	end
end
