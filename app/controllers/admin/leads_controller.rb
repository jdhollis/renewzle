class Admin::LeadsController < AdminController
  ssl_required :index, :show
  
	def index
    respond_to do |format|
      format.html do
		    @leads = Lead.paginate(:per_page => 20, :page => params[:page])
      end
      format.rss do
        @leads = Lead.recent
        render :layout => false
      end
    end
	end	

	def show
		@lead = Lead.find(params[:id])
	end
end
