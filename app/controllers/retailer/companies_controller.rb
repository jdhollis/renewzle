class Retailer::CompaniesController < RetailerController
  ssl_required :edit, :update
  
	before_filter :verify_partner_permissions
	
	def edit
		@location = 'companies'
		@view_title = 'My Company'
		@company = @partner.company
	end	

	def update
		@partner.company.update_from(params[:company])
		flash[:notice] = 'Company updated.'
		redirect_to(retailer_dashboard_url)
	rescue ActiveRecord::RecordInvalid
    @company = @partner.company
		render(:action => 'edit')
	end

private

	def verify_partner_permissions
		unless @partner.can_update_company_profile
			flash[:notice] = 'You do not have the permissions to perform that action.'
			redirect_to(retailer_dashboard_url)
		end
	end
end
