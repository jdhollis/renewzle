class Admin::IncentivesController < AdminController
  ssl_required :index, :show, :edit, :update, :destroy
  
	def index
		@incentives = Incentive.paginate(:per_page => 20, :page => params[:page])
	end	

	def show
		@incentive = Incentive.find(params[:id])
	end

	def edit
		@incentive = Incentive.find(params[:id])
	end

	def update
		@incentive = Incentive.find(params[:id])
		@incentive.update_from(params['incentive'])
		flash[:notice] = 'Incentive updated.'
		redirect_to(admin_incentives_url)
	rescue ActiveRecord::RecordInvalid
		render(:action => 'edit')
	end

	def destroy
		@incentive = Incentive.find(params[:id])
		@incentive.destroy
		flash[:notice] = 'Incentive has been removed.'
		redirect_to(admin_incentives_url)
	end
end
