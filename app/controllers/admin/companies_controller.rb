class Admin::CompaniesController < AdminController
  ssl_required :index, :show, :edit, :update, :destroy
  
  def index
    respond_to do |format|
      format.html do
        @filter = params[:filter]
        case @filter
        when'claimed'
          @companies = Company.paginate(:conditions => { :claimed => true }, :order => 'name', :per_page => 20, :page => params[:page])
        when 'unclaimed'
          @companies = Company.paginate(:conditions => { :claimed => false }, :order => 'name', :per_page => 20, :page => params[:page])
        else
          @companies = Company.paginate(:order => 'name', :per_page => 20, :page => params[:page])
        end
      end
      format.rss do
        @companies = Company.recently_claimed
        render(:layout => false)
      end
    end
  end	

  def show
    @company = Company.find(params[:id])
  end

  def edit
    @company = Company.find(params[:id])
  end

  def update
    @company = Company.find(params[:id])
    @company.update_from(params['company'])
    flash[:notice] = "#{@company.name} updated."
    redirect_to(admin_companies_url)
  rescue ActiveRecord::RecordInvalid
    render(:action => 'edit')
  end
	
  def destroy
    @company = Company.find(params[:id])
    @company.destroy
    flash[:notice] = "#{@company.name} has been removed."
    redirect_to(admin_companies_url)
  end
end
