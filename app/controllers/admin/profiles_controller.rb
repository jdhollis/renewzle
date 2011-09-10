class Admin::ProfilesController < AdminController
  ssl_required :index, :show, :edit, :update, :destroy
  
  def index
    respond_to do |format|
      format.html do
        @filter = params[:filter]
        case @filter
        when 'rfqs'
          @profiles = Profile.paginate(:conditions => { :rfq => true }, :per_page => 20, :page => params[:page])
        else
          @profiles = Profile.paginate(:per_page => 20, :page => params[:page])
        end
      end
      format.rss do
        @profiles = Profile.recent
        render :layout => false
      end
    end
  end	

  def show
    @profile = Profile.find(params[:id])
  end

  def edit
    @profile = Profile.find(params[:id])
  end
	
  def update
    respond_to do |format|
      format.html do
        @profile = Profile.find(params[:id])
        @profile.update_from(params['profile'])
        (params[:profile][:approved] == 'true') ? @profile.approve! : @profile.decline! if params[:profile][:approved]
        flash[:notice] = 'Profile updated.'
        redirect_to(admin_profiles_url)
      end

      format.js do
        @profile = Profile.find(params[:id])
        (params[:profile][:waiting_approval] == 'approve') ? @profile.approve! : @profile.decline!
        render(:update) do |page|
          page.visual_effect(:fade, dom_id(@profile))
        end
      end
    end
  rescue ActiveRecord::RecordInvalid
    render(:action => 'edit')
  end

  def destroy
    @profile = Profile.find(params['id'])
    @profile.withdraw!
    
    respond_to do |wants|
			wants.html do
				flash[:notice] = 'The RFQ has been withdrawn.'
				redirect_to(admin_profiles_url)
			end
			wants.js do 
				render(:update) do |page|
					page.visual_effect(:fade, dom_id(@profile))
					page.replace_html('messages', content_tag('p', 'The RFQ has been withdrawn.', :class => 'notice'))
					page.visual_effect(:highlight, 'messages')
				end
			end
		end
  end
end
