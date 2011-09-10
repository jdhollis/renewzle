class Admin::BackgroundersController < AdminController
  ssl_required :index, :edit, :update, :destroy, :approve, :reject, :confirm_reject
  
  # GET /admin/backgrounders
  # GET /admin/backgrounders.rss
  def index
    per_page = 20
    respond_to do |format|
      format.html do
        @filter = params[:filter]
        case @filter
        when 'all'
          @company_backgrounders = CompanyBackgrounder.paginate(
            :order    => 'title', 
            :per_page => per_page, 
            :page     => params[:page]
          )
        when 'rejected'
          @company_backgrounders = CompanyBackgrounder.paginate(
            :conditions => { :waiting_approval => false, :approved => false }, 
            :order      => 'reviewed_at', 
            :per_page   => per_page, 
            :page       => params[:page]
          )
        when 'approved'
          @company_backgrounders = CompanyBackgrounder.paginate(
            :conditions => { :waiting_approval => false, :approved => true }, 
            :order      => 'reviewed_at', 
            :per_page   => per_page, 
            :page       => params[:page]
          )
        else
          @company_backgrounders = CompanyBackgrounder.paginate(
            :conditions => { :waiting_approval => true }, 
            :order      => 'created_at', 
            :per_page   => per_page, 
            :page       => params[:page]
          )
        end
      end
      format.rss do
        @company_backgrounders = CompanyBackgrounder.last_waiting_approval
        render(:layout => false)
      end
    end
  end

  # GET /admin/backgrounders/1/edit
  def edit
    @company_backgrounder = CompanyBackgrounder.find(params[:id])
  end

  # PUT /admin/backgrounders/1
  def update
    @company_backgrounder = CompanyBackgrounder.find(params[:id])
    respond_to do |format|
      format.html do
        if @company_backgrounder.update_attributes(params[:company_backgrounder])
          flash[:notice] = 'CompanyBackgrounder was successfully updated.'
          redirect_to(admin_backgrounders_url)
        else
          render :action => "edit"
        end
      end
      format.js do
        if params[:backgrounder][:waiting_approval] == 'approve'
          @company_backgrounder.approve
          render(:update) do |page|
            page.visual_effect(:fade, dom_id(@company_backgrounder))
          end
        else
          render(:update) do |page|
            page.redirect_to reject_admin_backgrounder_url(@company_backgrounder)
          end
        end
      end
    end
  end

  # DELETE /admin/backgrounders/1
  def destroy
    @company_backgrounder = CompanyBackgrounder.find(params[:id])
    @company_backgrounder.destroy
    flash[:notice] = 'Company Backgrounder has been removed.'
    redirect_to(admin_backgrounders_url)
  end
  
  # GET /admin/backgrounders/1/approve
  def approve
    @company_backgrounder = CompanyBackgrounder.find(params[:id])
    @company_backgrounder.approve
    
    redirect_to(admin_backgrounders_url)
  end
  
  # GET /admin/backgrounders/1/reject
  def reject
    @company_backgrounder = CompanyBackgrounder.find(params[:id])
  end
  
  # POST /admin/backgrounders/1/reject
  def confirm_reject
    @company_backgrounder = CompanyBackgrounder.find(params[:id])
    @company_backgrounder.reject(params[:company_backgrounder][:comments])
    
    redirect_to(admin_backgrounders_url)
  end
end
