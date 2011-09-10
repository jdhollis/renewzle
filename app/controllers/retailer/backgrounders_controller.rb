class Retailer::BackgroundersController < RetailerController
  before_filter :verify_partner_permissions

  def index
    @backgrounders = get_backgrounders(params)
    @backgrounder = new_backgrounder()
    @location = "backgrounders"
    @view_title = "Company Backgrounders"
  end
  
  def create
    params[:company_backgrounder][:company_id] = @partner.company.id
    params[:company_backgrounder][:partner_id] = @partner.id
    @backgrounder = new_backgrounder(params[:company_backgrounder])
    @backgrounder.save!
    flash[:notice] = "#{@backgrounder.title} has been created."
    redirect_to(retailer_backgrounders_url)
  rescue ActiveRecord::RecordInvalid => e
    @backgrounders = get_backgrounders(params)
    render(:action => 'index')
  end
  
  def destroy
    @backgrounder = CompanyBackgrounder.find(params[:id], :conditions => { :company_id => @partner.company.id })
    if @backgrounder
      @backgrounder.destroy
      flash[:notice] = "#{@backgrounder.title} has been removed."
    end
    redirect_to(retailer_backgrounders_url)
  end
  
private

  def get_backgrounders(params)
    backgrounders = CompanyBackgrounder.paginate(
      :all, 
      :conditions => ["company_id = ?", @partner.company.id], 
      :per_page => 10, 
      :page => params[:page]
    )
    backgrounders
  end
  
  def new_backgrounder(params = nil)
    backgrounder = CompanyBackgrounder.new(params)
    backgrounder.waiting_approval = true
    backgrounder.approved = false
    backgrounder
  end
  
  def verify_partner_permissions
    unless @partner.can_manage_company_backgrounders
      flash[:notice] = 'You do not have the permissions to perform that action.'
      redirect_to(retailer_dashboard_url)
    end
  end
end
